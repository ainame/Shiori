class AppDelegate < PM::Delegate
  def on_load(app, options)
    open_split_screen BookMarkScreen, GithubScreen
  end
end
