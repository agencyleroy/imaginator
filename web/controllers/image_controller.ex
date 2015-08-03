defmodule Imaginator.ImageController do
  use Imaginator.Web, :controller

  def show(conn, _params) do
    # Do the processing in an external process using GenServer
    {:ok, pid} = Placeholder.Imaginator.start_link(Imaginator)
    Placeholder.Imaginator.process(pid, {_params})

    image = Placeholder.Imaginator.get(pid, :image)

    # Set date for expires header according to RFC1123 standard
    date = :calendar.universal_time
     |>  Timex.Date.from
     |>  Timex.Date.shift(secs: 24*3600*365)
     |>  Timex.DateFormat.format("{RFC1123}")

    conn
      |> put_resp_content_type("image/jpeg")
      |> put_resp_header("content-disposition", "filename=agency_leroy_placeholder.jpg")
      |> put_resp_header("cache-control", "public, max-age=31536000")
      |> put_resp_header("expires", "#{elem(date, 1)}")
      |> send_file(200, image)
  end

end
