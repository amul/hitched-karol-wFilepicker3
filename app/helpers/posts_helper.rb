module PostsHelper
  def get_img_url(filepicker_url)
    if filepicker_url.include?("convert?")
      return filepicker_url.split("/convert?").first
    else
      return filepicker_url
    end
  end
end
