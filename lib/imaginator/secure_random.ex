defmodule SecureRandom do
  @moduledoc """
  Ruby-like SecureRandom module.

  ## Examples

      iex> SecureRandom.base64
      "xhTcitKZI8YiLGzUNLD+HQ=="

      iex> SecureRandom.urlsafe_base64(4)
      "pLSVJw"

  """

  @default_length 16

  @doc """
  Returns random Base64 encoded string.

  ## Examples
    
      iex> SecureRandom.base64
      "rm/JfqH8Y+Jd7m5SHTHJoA=="

      iex> SecureRandom.base64(8)
      "2yDtUyQ5Xws="

  """
  def number(int) do
    :random.seed(:erlang.now)
    :random.uniform(int)
  end


  def base64(16) when is_integer 16 do
    random_bytes(16)
    |> :base64.encode_to_string
    |> to_string
  end

  @doc """
  Returns random urlsafe Base64 encoded string.

  ## Examples

      iex> SecureRandom.urlsafe_base64
      "xYQcVfWuq6THMY_ZVmG0mA"

      iex> SecureRandom.urlsafe_base64(8)
      "8cN__l-6wNw"

  """
  def urlsafe_base64(16) when is_integer 16 do
    random_bytes(16)
      |> :base64.encode_to_string
      |> to_string
      |> String.replace(~r/\=/, "")
      |> String.replace(~r/\+/, "-")
      |> String.replace(~r/\//, "_")
  end

  @doc """
  Returns random hex string.
  
  ## Examples

      iex> SecureRandom.hex
      "c3d3b6cdab81a7382fbbae33407b3272"

      iex> SecureRandom.hex(8)
      "125583e32b698259"

  """


  @doc """
  Returns UUID v4. Not implemented yet.
  """
  def uuid do
    raise NotImplemented
  end


  @doc """
  Returns random bytes.
  
  ## Examples

      iex> SecureRandom.random_bytes
      <<202, 104, 227, 197, 25, 7, 132, 73, 92, 186, 242, 13, 170, 115, 135, 7>>

      iex> SecureRandom.random_bytes(8)
      <<231, 123, 252, 174, 156, 112, 15, 29>>

  """
  def random_bytes(16) when is_integer 16 do
    :crypto.strong_rand_bytes(16)
  end
end