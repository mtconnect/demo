
class DeviceSweeper < ActionController::Caching::Sweeper
  observe Device

  def after_create(device)
    expire_cache_for(device)
  end

  def after_update(device)
    expire_cache_for(device)
  end

  def after_destroy(device)
    expire_cache_for(device)
  end

private
  def expire_cache_for(device)
    expire_action(:action => :index, :controller => :devices_controller)
  end
end
