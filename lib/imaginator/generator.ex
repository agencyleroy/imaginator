defmodule Placeholder.Generator do
  import Mogrify

  @max_width    3000
  @max_height   3000
  @default_text "Agency\\nLeroy"

  @doc "Opens a random file for processing and returns the new processed image"
  def render_image(params) do
    number     = SecureRandom.number(7) # Randomly select an image
    image      = open("./priv/static/images/#{number}.jpg")
    image_copy = image # Save a copy of the original version

    image
      |> copy
      |> format("jpg")
      |> create_image(params, image_copy)
  end

  @doc "Creates a new image by combining a grey rectangle with a randomly chosen image"
  def create_image(image, params, image_copy) do
    # Sanitize the parameters being sent and make sure that they don't exceed the max width/height
    width  = sanitize_width(params["width"])
    height = sanitize_height(params["height"])

    text = if params["text"] != nil do
      String.replace(params["text"], " ", "\\n")
    else
      @default_text
    end

    {_, 0} = System.cmd "convert", ~w(-size #{width}x#{height} xc:grey #{String.replace(image.path, " ", "\\ ")}), stderr_to_stdout: true
    System.cmd "composite", ~w(-gravity Center -geometry #{width}^x#{height}^+0+0 #{image_copy.path} #{image.path} #{image.path}), stderr_to_stdout: true
    System.cmd "mogrify",  ~w(-gravity Center -family Helvetica -fill white -pointsize 24 -annotate 0 #{text} #{String.replace(image.path, " ", "\\ ")}), stderr_to_stdout: true
    image
  end

  defp sanitize_width(width) do
    if elem(Integer.parse(width), 0) <= @max_width do
      width
    else
      @max_width
    end
  end

  defp sanitize_height(height) do
    if elem(Integer.parse(height), 0) <= @max_height do
      height
    else
      @max_height
    end
  end
end