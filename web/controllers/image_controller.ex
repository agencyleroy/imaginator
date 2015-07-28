defmodule Imaginator.ImageController do
  import Mogrify

  use Imaginator.Web, :controller

  def show(conn, _params) do
    img    = render_image(_params)
    random = SecureRandom.urlsafe_base64(16)

    conn
      |> put_resp_content_type("image/jpeg")
      |> put_resp_header("content-disposition", "attachment; filename=agency_leroy_#{random}.jpg")
      |> put_resp_header("cache-control", "public, max-age=31536000")
      |> send_file(200, img.path)
  end

  #
  # Image transformation methods
  #
  def create_image(image, params, image2) do
    {_, 0} = run_convert(image.path, "size", "#{params["width"]}x#{params["height"]} xc:grey")
    System.cmd "composite", ~w(-gravity Center -geometry #{params["width"]}^x#{params["height"]}^+0+0 #{image2.path} #{image.path} #{image.path}), stderr_to_stdout: true
    run_mogrify(image.path, "gravity", "Center -family VenusSBOP-MediumExtended -kerning 5 -fill white -pointsize 24 -annotate 0 Agency\\nLeroy")
    image |> verbose
  end

  def render_image(params) do
    image = open("./priv/static/images/lundia.jpg")
    image2 = image

    image
      |> copy
      |> format("jpg")
      |> create_image(params, image2)
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
