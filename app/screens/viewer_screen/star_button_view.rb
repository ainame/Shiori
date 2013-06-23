class ViewerScreen < PM::Screen
  class StarButtonView 
    STAR_STATUSES = [:on, :off, :other]

    def initialize(viewer_screen)
      @viewer_screen  = WeakRef.new(viewer_screen)
      set_current_star_state
      create_button
    end

    def create_button
      return nil if @star_state == :other

      button = UIButton.buttonWithType(UIButtonTypeCustom).tap do |b|
        image = UIImage.imageNamed( is_starred ?
          "iconbeast/tick" : "iconbeast/star" )
        b.setImage(image, forState: UIControlStateNormal)
        b.frame = CGRectMake(0,0,25,25)
        b.addTarget(self, action: :click_star_button, forControlEvents: UIControlEventTouchUpInside)
      end

      UIBarButtonItem.alloc.initWithCustomView(button)
    end

    def set_current_star_state
      set_star_state(get_current_star_state)
    end

    private
    def flip_star_state
      @star_state = @star_state == :on ? :off : :on
    end

    def is_starred
      @star_state == :on
    end

    def set_star_state(star_state)
      @star_state = STAR_STATUSES.include?(star_state.to_sym) ? 
        star_state.to_sym : :other
    end

    def click_star_button
      idx = is_starred ? 0 : 1
      script = <<"JS"
$($(".star-button")[#{idx}]).click();
JS
      @viewer_screen.eval_js_src(script)
      @viewer_screen.navigationItem.
        rightBarButtonItem = create_button
      flip_star_state
    end

    def get_current_star_state
      script = <<JS
(function(){
  if ($(".star-button")[0] === undefined){
    return "other";
  }
  else if ($($(".star-button")[0]).parent().hasClass("on")) {
    return "on";
  }
  else {
    return "off";
  }
})();
JS
      @viewer_screen.eval_js_src(script)
    end

  end
end
