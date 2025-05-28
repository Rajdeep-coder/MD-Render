class AppVersionsController < ApplicationController
  skip_before_action :authenticate_request

  def latest
    app_name = params[:name]
    platform = params[:platform]

    latest_version = AppVersion.where(name: app_name, platform: platform).order(version: :desc).first

    if latest_version
      render json: {
        latest_version: latest_version.version,
        required: latest_version.required
      }
    else
      render json: { error: "Version not found" }, status: 404
    end
  end
end
