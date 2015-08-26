defmodule Imaginator.ImageController do
  use Imaginator.Web, :controller

  def show(conn, _params) do
    # Set date for expires header according to RFC1123 standard
    date = :calendar.universal_time
     |>  Timex.Date.from
     |>  Timex.Date.shift(secs: 24*3600*365)
     |>  Timex.DateFormat.format("{RFC1123}")

    # Manually set and check etag headers
    {{year, month, day}, {hours, minutes, seconds}} = :calendar.universal_time
    etag = "y#{year}m#{month}d#{day}h#{hours}w#{_params["width"]}h#{_params["height"]}c#{_params["category"]}t#{_params["text"]}"
    header = "#{get_req_header(conn, "if-none-match")}"

    # Only generate a new image if the parameters have changed
    if header != etag do
      # Do the processing in an external process using GenServer
      case Placeholder.Imaginator.start_link(Imaginator) do
        {:ok, pid} ->
          Placeholder.Imaginator.process(pid, {_params})
          image = Placeholder.Imaginator.get(pid, :image)
        {:error} ->
          raise "something went wrong"
      end

      conn
        |> put_resp_content_type("image/jpeg")
        |> put_resp_header("content-disposition", "filename=agency_leroy_placeholder.jpg")
        |> put_resp_header("cache-control", "public, max-age=31536000")
        |> put_resp_header("expires", "#{elem(date, 1)}")
        |> put_resp_header("etag", etag)
        |> send_file(200, image)

    else
      conn
        |> put_resp_content_type("image/jpeg")
        |> put_resp_header("content-disposition", "filename=agency_leroy_placeholder.jpg")
        |> put_resp_header("cache-control", "public, max-age=31536000")
        |> put_resp_header("expires", "#{elem(date, 1)}")
        |> put_resp_header("etag", etag)
        |> send_resp(304, "")
    end
  end

end
