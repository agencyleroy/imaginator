defmodule Placeholder.Generator do
  import Mogrify

  @max_width    3000
  @max_height   3000
  @default_text "Agency\\nLeroy"

  @doc "Opens a random file for processing and returns the new processed image"
  def render_image(params) do
    image      = select_image(params)
    image_copy = image # Save a copy of the original version

    image
      |> copy
      |> format("jpg")
      |> create_image(params, image_copy)
  end

  @doc "Creates a new image by combining a grey rectangle with a randomly chosen image"
  def create_image(image, params, image_copy) do
    # Sanitize the parameters being sent and make sure that they don't exceed the max width/height
    {width, height} = sanitize_resolution({params["width"], params["height"]})

    # Set the text if defined
    text = if params["text"] != nil do
      String.replace(params["text"], " ", "\\n")
    else
      @default_text
    end

    {_, 0} = System.cmd "convert", ~w(-size #{width}x#{height} xc:grey #{String.replace(image.path, " ", "\\ ")}), stderr_to_stdout: true
    System.cmd "composite", ~w(-gravity Center -geometry #{width}^x#{height}^+0+0 #{image_copy.path} #{image.path} #{image.path}), stderr_to_stdout: true
    System.cmd "mogrify",  ~w(-gravity Center -family Helvetica -fill white -pointsize 24 -annotate 0 #{text} #{String.replace(image.path, " ", "\\ ")}), stderr_to_stdout: true
    {:ok, image}
  end

  @doc "Randomly selects and image based on params"
  def select_image(params) do
    # Search images from category
    category = if params["category"] != nil do
      String.replace(params["category"], " ", "\\n")
    else
      "." # All images
    end

    total  = if category == "food" do
      11
    else
      7
    end

    number = SecureRandom.number(total) # Randomly generate a number for image selection
    path   = elem(File.cwd, 1) <> "/priv/static/images/#{category}/#{number}.jpg"

    open(path)
  end

  defp sanitize_resolution({width, height}) do
    width  = Integer.parse(width)
    height = Integer.parse(height)
    {normalize_width(width), normalize_height(height)}
  end

  defp normalize_width(width) when is_number(elem(width, 0)) do
    width = elem(width, 0)
    if width > @max_width, do: @max_width, else: width
  end

  defp normalize_width(:error) do
    100
  end

  defp normalize_height(height) when is_number(elem(height, 0)) do
    height = elem(height, 0)
    if height > @max_height, do: @max_height, else: height
  end

  defp normalize_height(:error) do
    100
  end
end