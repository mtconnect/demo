module FixtureReplacement
  attributes_for :device do |a|
    a.name = String.random(12)
    a.url = 'http://localhost:3000/'
    a.description = String.random(32)
    a.application = false
    a.button = default_button
    a.picture = default_picture
  end

  attributes_for :image do |a|
    a.size = 100_000
    a.content_type = 'image/jpg'
    a.filename = String.random(12)
    a.height = 80
    a.width = 80
  end

  attributes_for :picture, :from => :image, :class => Picture do |a|
    a.type = 'Picture'
  end

  attributes_for :button, :from => :image, :class => Button do |a|
    a.type = 'Button'
  end
end
