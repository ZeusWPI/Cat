defmodule CatexWeb.Router do
  @moduledoc false

  use CatexWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CatexWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Catex.Authenticator
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CatexWeb do
    pipe_through :browser

    get "/", PageController, :index

    live "/hugs", HugLive.Index, :index
    live "/hugs/new", HugLive.Index, :new
    live "/hugs/:id/edit", HugLive.Index, :edit

    live "/hugs/:id", HugLive.Show, :show
    live "/hugs/:id/show/edit", HugLive.Show, :edit

    resources "/users", UserController

    get "/auth/login", AuthController, :login
    get "/auth/logout", AuthController, :logout
    get "/auth/callback", AuthController, :callback
  end

  # Other scopes may use custom stacks.
  scope "/api", CatexWeb do
    pipe_through :api

    get "/hugs", HugController, :index
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard",
        metrics: CatexWeb.Telemetry

      #                     additional_pages: [
      #                       _profiler: {PhoenixProfiler.Dashboard, []}
      # additional pages...
      #                     ]
    end
  end

  scope "/admin", CatexWeb.Admin, as: :admin do
    pipe_through :browser

    resources "/users", UserController
    resources "/hugs", HugController
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
