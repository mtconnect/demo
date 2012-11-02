module DevicesHelper
  def format_device_app_url(app_url, device_url)
    url = app_url.dup
    if app_url.index("?")
      url << '&'
    else
      url << '?'
    end
    durl = device_url.sub!("localhost", "imts.mtconnect.org")
    url << "device=#{device_url}"
  end
      
  def display_row(text, item)
    res = <<-EOF
    <td class="name">#{text}</td>
    <td class="sub-type">#{item.sub_type}</td>
    EOF
    if (item.is_a? Device::Condition)
      res << %{<td class="value-type">#{item.value_type}</td>}
    end
    res << %{<td class="value">#{item.value}</td>}
    res
  end
end
