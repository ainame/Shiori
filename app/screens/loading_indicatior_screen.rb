class LoadingIndicatorScreen
  def initialize target
    super
    @target = WeakRef.new(target)
    create_indicator
  end

  def start
    @indicator.startAnimating
  end

  def stop
    return unless @indicator.respond_to?(:stopAnimating)
    @indicator.stopAnimating
    @indicator.removeFromSuperview
    @view.removeFromSuperview
    @indicator = nil
    @view = nil    
  end

  def create_indicator
    @view = UIView.alloc.initWithFrame @target.view.frame
    @view.backgroundColor = UIColor.blackColor
    @view.alpha = 0.8

    @indicator = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle UIActivityIndicatorViewStyleWhiteLarge
    @indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite
    @indicator.setCenter CGPointMake(@view.bounds.size.width / 2, @view.bounds.size.height / 2)

    @view.addSubview @indicator
    @target.view.addSubview @view
  end
end
