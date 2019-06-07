defmodule Servy.VideoCam do
  @doc false

  def get_snapshot(camera_name) do
    :timer.sleep(1000)

    "#{camera_name}-snapshot.jpg"
  end
end
