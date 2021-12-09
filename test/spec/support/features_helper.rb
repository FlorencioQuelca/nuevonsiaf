module FeaturesHelper
  # Para introducir enter después de llenar un dato por ejemplo en calendario
  def presionar_enter(field)
    page.execute_script %Q{ $('##{field}').trigger($.Event('keydown', {keyCode: 13})) }
  end

  # Llena datos para el plugin autocomplete typeahead de Twitter Bootstrap
  def fill_autocomplete(field, options = {})
    fill_in field, with: options[:with]

    page.execute_script %Q{ $('##{field}').trigger('focus') }
    page.execute_script %Q{ $('##{field}').trigger('keydown') }
    selector = %Q{span.tt-dropdown-menu .tt-suggestion p:contains("#{options[:select]}")}

    expect(page).to have_selector('span.tt-dropdown-menu .tt-suggestion p')
    page.execute_script %Q{ $('#{selector}').trigger('mouseenter').click() }
  end
end

RSpec.configure do |config|
  config.include FeaturesHelper, type: :feature
end
