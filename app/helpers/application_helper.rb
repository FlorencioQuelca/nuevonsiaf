module ApplicationHelper
  ##
  # Mime-types para los archivos *.dbf
  def dbf_mime_types
    %w(application/dbase application/x-dbase application/dbf application/x-dbf zz-application/zz-winassoc-dbf)
  end

  def entidad_sigla
    acronym = 'ADSIB'
    entity = Entity.first
    acronym = entity.acronym if entity.present?
    acronym
  end

  def entidad_actual
    Entity.first
  end

  ##
  # Muestra la fecha de impresión en el lugar especificado
  # También soporta enviarle
  def fecha_impresion(fecha_hora = DateTime.now)
    content_tag(:p, class: 'text-right') do
      content_tag :em, "Impreso el #{I18n.l fecha_hora, format: :long}"
    end
  end

  # Firmas para la solicitud de salida de almacenes
  def firmas_salidas(estado = 'initiation')
    case estado
    when 'initiation'
      ['Solicitante']
    when 'delivered'
      ['Entregado por', 'V.° B.°', 'Recibí conforme', '', 'V.° B.° Inmediato superior']
    else
      []
    end
  end

  def get_accounts(assets = false)
    accounts = assets == true ? Account.con_activos : Account.all
    accounts.order(:code).map { |b| [b.code_and_name, b.id] }
  end

  def get_buildings
    Building.all.map { |b| [b.name, b.id] }
  end

  def get_materials
    status_active(Material).map { |b| [b.description, b.id] }
  end

  def get_i18n_roles
    User::ROLES.map { |r| [t(r, scope: 'users.roles'), r] }
  end

  def get_ubicaciones
    Ubicacion.order(:abreviacion)
  end

  def is_pdf?
    params['format'] == 'pdf'
  end

  # permite extraer la lista de campos
  def listar_campos(activos)
    campos = %w(detalle medidas material marca modelo serie color)
    activos.inject([]) do |seleccionados, activo|
      seleccionados + campos.select { |c| activo[c].present? }
    end.uniq
  end

  # http://stackoverflow.com/a/18163626/1174245
  # Si la cantidad no tiene decimales lo muestra como entero
  def mostrar_entero_float(cantidad)
    cantidad % 1 == 0 ? cantidad.to_i : cantidad
  end

  def proceeding_to_json(proceeding)
    assets = proceeding.assets.order(:code).each_with_index.map do |a, index|
      { index: index + 1, id: a.id, description: a.description, code: a.code, state: a.get_state, auxiliary: a.auxiliary_name, cuenta: a.account_name }
    end
    cite_plantillas = obtener_cite(proceeding)
    respuesta = {
      #admin_name: proceeding.admin_name.titleize,
      assets: assets.to_json,
      proceeding_date: I18n.l(proceeding.fecha.to_date, format: :long),
      devolution: proceeding.is_devolution?,
      user_name: proceeding.user_name,
      user_ci: proceeding.user_ci,
      user_title: proceeding.user_title,
      user_department: proceeding.user_department,
      count: assets.count,
      entity: "#{Entity.first.code} - #{Entity.first.name}",
      institucion: Entity.first.name,
      sigla: Entity.first.acronym
    }
    cite_plantillas.present? ? respuesta['cite_plantillas'] = cite_plantillas : ''
    respuesta
  end

  def obtener_cite(proceeding)
    if proceeding.present? && proceeding.plantillas_info.present?
      info_plantillas = JSON.parse(proceeding.plantillas_info) rescue ''
      info_plantillas.present? ? info_plantillas['cite'] : ''
    else
      ''
    end
  end

  def selected_assets_json(assets)
    { assets: assets_json(assets) }
  end

  def assets_json(assets)
    assets.each_with_index.map do |a, index|
      { index: index + 1, id: a.id, description: a.description, code: a.code, barcode: a.barcode, user_name: a.user_name }
    end
  end

  def subarticles_json(subarticles)
    subarticles.each.map do |a|
      { id: a.id, description: a.description, code: a.code, barcode: a.barcode }
    end
  end

  def proceedings_json(proceedings)
    proceedings = proceedings.each_with_index.map do |p, index|
      {
        index: index + 1,
        created_at: I18n.l(p.created_at, format: :version),
        devolution: p.is_devolution?,
        user_name: p.user_name.titleize,
        user_url: user_url(p.user)
      }
    end
  end

  def submit_and_cancel(url)
    content_tag(:button, class: 'btn btn-primary') do
      content_tag(:span, '', class: 'glyphicon glyphicon-ok') + ' ' +
      t("general.btn.save")
    end + ' ' +
    link_to(url, class: 'btn btn-danger') do
      content_tag(:span, '', class: 'glyphicon glyphicon-remove') + ' ' +
      t("general.btn.cancel")
    end
  end

  def title(page_title)
    content_for(:title) { page_title }
  end

  def type_status(status)
    state = status == '0' ? 'inactive' : 'active'
    t("general.#{state}")
  end

  def title_status(type)
    state = type == '0' ? 'active' : 'deactive'
    t("general.btn.#{state}")
  end

  def img_status(status)
    status == '0' ? 'ok' : 'remove'
  end

  def get_column(model, column)
    [model.human_attribute_name(column), column]
  end

  def data_link(model)
    assignment = model.verify_assignment
    if model.status == '1'
      state = assignment ? 'cannot_disable' : 'deactivate'
    else
      state = 'activate'
    end
    klass = model.class.name
    {
      dom_id: dom_id(model),
      title: t("#{ klass.tableize }.title.modal"),
      confirm_message: t("#{ klass.tableize }.title.confirm-#{ state }", name: %w(Material Article Subarticle).include?(klass) ? model.description :  ('ApiToken' == klass ? model.nombre : model.name)),
      url: eval("change_status_#{ klass.underscore }_path(model)"),
      unassigned: !assignment
    }
  end

  def data_entry_subarticle(subarticle)
    {
      id: subarticle.id,
      dom_id: dom_id(subarticle),
      title: I18n.t('subarticles.entry.first', description: subarticle.description),
      unassigned: false,
      entry: true
    }
  end

  def data_label(valor, type= 'default')
    content_tag(:span, valor, class: "label label-#{type}")
  end

  def boton_estado(user, type)
    unless %w(asset ingreso ubicacion ufv gestion seguro baja).include?(type)
      if can?(:update, user.class)
        link_to '#', class: 'btn btn-warning btn-xs', data: data_link(user), title: title_status(user.status) do
          content_tag(:span, '', class: "glyphicon glyphicon-#{img_status(user.status)}")
        end
      end
    end
  end

  def links_actions(user, type= '')
    [
      (link_to(content_tag(:span, '', class: 'glyphicon glyphicon-eye-open'), user, class: 'btn btn-default btn-xs', title: I18n.t('general.btn.show')) unless %w(ubicacion ufv).include?(type)),
      (link_to(content_tag(:span, '', class: 'glyphicon glyphicon-edit'), [:edit, user], class: 'btn btn-primary btn-xs', title: I18n.t('general.btn.edit')) if (can?(:update, user)) && !%w(baja).include?(type)),
      boton_estado(user, type),
      (link_to(content_tag(:span, '', class: "glyphicon glyphicon-plus"), '#', class: 'btn btn-success btn-xs', data: data_entry_subarticle(user), title: I18n.t('subarticles.entry.btn')) if type == 'subarticle')
    ].compact.join(' ')
  end

  def status_active(model)
    orden = :name
    if model == Material || model == Asset
      orden = :description
    end
    model.where(status: '1').order(orden)
  end

  def yield_or_default(section, default = "")
    content_for?(section) ? content_for(section) : default
  end

  def add_check_box(version_id)
    check_box_tag 'id', version_id
  end

  def link_request(status)
    link_to title_request(status), requests_path(status: status)
  end

  def link_asset(status)
    link_to title_asset(status), assets_path(status: status)
  end

  def title_request(status)
    status = status.present? ? status : 'initiation'
    t("requests.title.status.#{status}") + 's'
  end

  def title_asset(status)
    status = status.present? ? status : 'sin_bajas'
    t("requests.title.status.#{status}")
  end

  def get_url_request(status)
    r_referer = request.referer
    r_referer.present? && URI(r_referer).query ? (URI(r_referer).path + '?' + URI(r_referer).query) : requests_path(status: status)
  end

  def minimum_stock
    Subarticle.active.minimum_stock(1.25)
  end

  def img_pdf(type)
    img = current_user.get_image(type) rescue ''
    img.present? ? pdf_image_tag(img, class: "image") : ''
  end

  def pdf_image_tag(image, options = {})
    options[:src] = File.expand_path(Rails.root) + '/public' + image
    tag(:img, options)
  end

  def search_asset_subarticle(model, q)
    model.where("code LIKE ? OR description LIKE ?", "%#{q}%", "%#{q}%").limit 5
  end

  # Unit for Bolivia
  def number_to_money number
    number_to_currency number,
      precision: 2,
      unit: 'Bs',
      separator: '.',
      delimiter: ',',
      format: '%u%n'
  end

  def number_with_delimiter number, precision=2
    number_with_precision number,
      precision: precision,
      separator: '.',
      delimiter: ','
  end

  def title_system
    case current_user.role
    when 'super_admin' then 'Sistema de Activos Fijos y Almacenes'
    when 'admin' then 'Sistema de Activos Fijos'
    when 'admin_store' then 'Sistema de Almacenes'
    when 'observador_almacen' then 'Sistema de Almacenes'
    end
  end

  def titulo_rango_de_fechas(desde, hasta)
    "Desde #{I18n.l desde, format: :fecha} al #{I18n.l hasta, format: :fecha}"
  end

  def titulo_a_la_fecha(hasta)
    "Al #{I18n.l hasta.to_date, format: :long}"
  end

  def color_menu
    case current_user.role
    when 'super_admin' then 'navbar-sa'
    when 'admin_store' then 'navbar-stores'
    when 'admin' then 'navbar-act'
    when 'observador_almacen' then 'navbar-stores'
    else
      ''
    end
  end

  def acronym_entity
    user = current_user.department
    if user.present?
      user = user.building
      if user.present?
        user = user.entity
        if user.present?
          "de #{user.acronym}" || ''
        else
          ""
        end
      else
        ""
      end
    else
      ""
    end
  end

  def dashboard_text
    case current_user.role
    when 'super_admin' then 'la administración del sistema'
    when 'admin' then 'los activos de su institución'
    when 'admin_store' then 'los artículos de su institución'
    when 'observador_almacen' then 'los artículos de su institución'
    end
  end

  def changeBarcode(q)
    a = q.sub! "'", "-"
    q = a.present? ? a : q
    return q
  end

  def format_date(date)
    date.present? ? (I18n.l date) : ''
  end

  # Para los documentos en tamaño carta con el logo de AGETIC
  def margin_pdf
    { top: 25, bottom: 20, left: 20, right: 15 }
  end

  # Para los documentos en tamaño carta con el logo de AGETIC
  def margin_pdf_horizontal_estrecho
    { top: 20, bottom: 10, left: 5, right: 5 }
  end

  def validar_valor(valor)
    valor.present? ? valor : ""
  end

  def validar_valor_registro(modelo, campo)
    begin
      (modelo.present? && modelo[campo].present?) ? modelo[campo] : ""
    rescue StandardError => e
      ""
    end
  end
end
