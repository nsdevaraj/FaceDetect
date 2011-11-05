package com.nsdevaraj.face
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Video;
	
	import spark.components.Image;

	/**
	 * Motion Tracker
	 */
	public class MotionTracker extends Point
	{
        private static const DEFAULT_AREA : int = 10;
		private static const DEFAULT_BLUR : int = 20;
		private static const DEFAULT_BRIGHTNESS : int = 20;
		private static const DEFAULT_CONTRAST : int = 150; 

		
        private var _src : Image;
		private var _now : BitmapData;
		private var _old : BitmapData;

		private var _blr : BlurFilter;
		private var _cmx : ColorMatrix;
		private var _col : ColorMatrixFilter;
		private var _box : Rectangle;
		private var _act : Boolean;
		private var _mtx : Matrix;
		private var _min : uint;

		private var _brightness : Number = 0.0;		private var _contrast : Number = 0.0;

		/**
		 * Initializes the module
		 * 
		 * @param source
		 * 
		 */
		public function MotionTracker( ) 
		{
			super();
			
			_cmx = new ColorMatrix();
			_blr = new BlurFilter();
			
			blur = DEFAULT_BLUR;
			minArea = DEFAULT_AREA;
			contrast = DEFAULT_CONTRAST;
			brightness = DEFAULT_BRIGHTNESS;
			
			applyColorMatrix();
		}

		//	----------------------------------------------------------------
		//	PUBLIC METHODS
		//	----------------------------------------------------------------
		
		/**
		 * Track movement within the source Video object.
		 */
		public function track() : void
		{
			_now.draw(_src, _mtx);
			_now.draw(_old, null, null, BlendMode.DIFFERENCE);
			
			_now.applyFilter(_now, _now.rect, new Point(), _col);
			_now.applyFilter(_now, _now.rect, new Point(), _blr);
			//trace(_now.rect);
			_now.threshold(_now, _now.rect, new Point(), '>', 0xFF333333, 0xFFFFFFFF);
			
			_old.draw(_src, _mtx);
			
			var area : Rectangle = _now.getColorBoundsRect(0xFFFFFFFF, 0xFFFFFFFF, true);
			_act = ( area.width > ( _src.width / 100) * _min || area.height > (_src.height / 100) * _min );
			
			if ( _act )
			{
				_box = area;
				x = _box.x + (_box.width / 2);
				y = _box.y + (_box.width / 2);
			}
		}

		private function applyColorMatrix() : void
		{
			_cmx.reset();
			_cmx.adjustContrast(_contrast);
			_cmx.adjustBrightness(_brightness);
			_col = new ColorMatrixFilter(_cmx);
		}

		
		public function get trackingImage() : BitmapData 
		{ 
			return _now; 
		}

		
		public function get trackingArea() : Rectangle 
		{ 
			return new Rectangle(_src.x, _src.y, _src.width, _src.height); 
		}

		
		public function get hasMovement() : Boolean 
		{ 
			return _act; 
		}

		
		public function get motionArea() : Rectangle 
		{ 
			return _box; 
		}

		
		public function get input() : Image 
		{ 
			return _src; 
		}

		public function set input( v : Image ) : void
		{
			_src = v;
			if ( _now != null ) 
			{ 
				_now.dispose(); 
				_old.dispose(); 
			}
			_now = new BitmapData(v.width, v.height, false, 0);
			_old = new BitmapData(v.width, v.height, false, 0);
		}

		
		public function get blur() : int 
		{ 
			return _blr.blurX; 
		}

		public function set blur( n : int ) : void 
		{ 
			_blr.blurX = _blr.blurY = n; 
		}

		
		public function get brightness() : Number 
		{ 
			return _brightness; 
		}

		public function set brightness( n : Number ) : void
		{
			_brightness = n;
			applyColorMatrix();
		}

				public function get contrast() : int 
		{ 
			return _cmx.contrast; 
		}

		public function set contrast( n : int ) : void
		{
			_contrast = n;
			applyColorMatrix();
		}

		
		public function get minArea() : uint 
		{ 
			return _min; 
		}

		public function set minArea( n : uint ) : void
		{
			_min = n;
		}

		
		public function get flipInput() : Boolean 
		{ 
			return _mtx.a < 1; 
		}

		public function set flipInput( b : Boolean ) : void
		{
			_mtx = new Matrix();
			if (b) 
			{ 
				_mtx.translate(-_src.width, 0); 
				_mtx.scale(-1, 1); 
			}
		}
	}
}
