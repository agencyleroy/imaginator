defmodule Imaginator.ImageController do
  import Mogrify

  use Imaginator.Web, :controller

  @max_width  3000
  @max_height 3000

  def show(conn, _params) do
    img    = render_image(_params)
    random = SecureRandom.urlsafe_base64(16)

    conn
      |> put_resp_content_type("image/jpeg")
      |> put_resp_header("content-disposition", "filename=agency_leroy_#{random}.jpg")
      |> put_resp_header("cache-control", "public, max-age=31536000")
      |> send_file(200, img.path)
  end

  #
  # Image transformation methods
  #
  def create_image(image, params, image_copy) do
    # Sanitize the parameters being sent and make sure that they don't exceed the max width/height
    width  = if elem(Integer.parse(params["width"]), 0) <= @max_width do
      params["width"]
    else
      @max_width
    end
    height = if elem(Integer.parse(params["height"]), 0) <= @max_height do
      params["height"]
    else
      @max_height
    end

    text = if params["text"] != nil do
      String.replace(params["text"], " ", "\\n")
    else
      "Agency\\nLeroy"
    end

    {_, 0} = run_convert(image.path, "size", "#{width}x#{height} xc:grey")
    System.cmd "composite", ~w(-gravity Center -geometry #{width}^x#{height}^+0+0 #{image_copy.path} #{image.path} #{image.path}), stderr_to_stdout: true
    run_mogrify(image.path, "gravity", "Center -family VenusSBOP-MediumExtended -kerning 5 -fill white -pointsize 24 -annotate 0 #{text}")
    image |> verbose
  end

  def render_image(params) do
    number     = SecureRandom.number(7) # Randomly select an image
    image      = open("./priv/static/images/#{number}.jpg")
    image_copy = image # Save a copy of the original version

    image
      |> copy
      |> format("jpg")
      |> create_image(params, image_copy)
      |> verbose
  end

  defp run_mogrify(path, option, params \\ nil) do
    args = ~w(-#{option} #{params} #{String.replace(path, " ", "\\ ")})
    System.cmd "mogrify", args, stderr_to_stdout: true
  end

  defp run_convert(path, option, params \\ nil) do
    args = ~w(-#{option} #{params} #{String.replace(path, " ", "\\ ")})
    System.cmd "convert", args, stderr_to_stdout: true
  end

end
