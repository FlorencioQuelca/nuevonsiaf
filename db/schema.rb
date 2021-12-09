# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20210112134500) do

  create_table "accounts", force: :cascade do |t|
    t.integer  "code",       limit: 4
    t.string   "name",       limit: 230
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "vida_util",  limit: 4,   default: 0,     null: false
    t.boolean  "depreciar",              default: false, null: false
    t.boolean  "actualizar",             default: false, null: false
    t.string   "status",     limit: 255, default: "1"
  end

  create_table "api_tokens", force: :cascade do |t|
    t.string   "email",            limit: 255,   null: false
    t.string   "nombre",           limit: 255,   null: false
    t.text     "token",            limit: 65535, null: false
    t.date     "fecha_expiracion"
    t.string   "status",           limit: 2
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "asset_proceedings", force: :cascade do |t|
    t.integer  "proceeding_id", limit: 4
    t.integer  "asset_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "asset_proceedings", ["asset_id"], name: "index_asset_proceedings_on_asset_id", using: :btree
  add_index "asset_proceedings", ["proceeding_id"], name: "index_asset_proceedings_on_proceeding_id", using: :btree

  create_table "assets", force: :cascade do |t|
    t.integer  "code",          limit: 4
    t.text     "description",   limit: 65535
    t.integer  "auxiliary_id",  limit: 4
    t.integer  "user_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",    limit: 4
    t.string   "barcode",       limit: 255
    t.integer  "state",         limit: 4
    t.text     "observation",   limit: 65535
    t.string   "proceso",       limit: 255
    t.string   "observaciones", limit: 255
    t.decimal  "precio",                      precision: 10, scale: 2, default: 0.0, null: false
    t.string   "detalle",       limit: 255
    t.string   "medidas",       limit: 255
    t.string   "material",      limit: 255
    t.string   "color",         limit: 255
    t.string   "marca",         limit: 255
    t.string   "modelo",        limit: 255
    t.string   "serie",         limit: 255
    t.integer  "ingreso_id",    limit: 4
    t.integer  "ubicacion_id",  limit: 4
    t.string   "code_old",      limit: 255
    t.integer  "baja_id",       limit: 4
    t.integer  "asset_id",      limit: 4
  end

  add_index "assets", ["account_id"], name: "index_assets_on_account_id", using: :btree
  add_index "assets", ["asset_id"], name: "index_assets_on_asset_id", using: :btree
  add_index "assets", ["auxiliary_id"], name: "index_assets_on_auxiliary_id", using: :btree
  add_index "assets", ["baja_id"], name: "index_assets_on_baja_id", using: :btree
  add_index "assets", ["ingreso_id"], name: "index_assets_on_ingreso_id", using: :btree
  add_index "assets", ["ubicacion_id"], name: "index_assets_on_ubicacion_id", using: :btree
  add_index "assets", ["user_id"], name: "index_assets_on_user_id", using: :btree

  create_table "assets_seguros", id: false, force: :cascade do |t|
    t.integer "asset_id",  limit: 4, null: false
    t.integer "seguro_id", limit: 4, null: false
  end

  add_index "assets_seguros", ["asset_id", "seguro_id"], name: "index_assets_seguros_on_asset_id_and_seguro_id", using: :btree
  add_index "assets_seguros", ["seguro_id", "asset_id"], name: "index_assets_seguros_on_seguro_id_and_asset_id", using: :btree

  create_table "auxiliaries", force: :cascade do |t|
    t.integer  "code",       limit: 4
    t.string   "name",       limit: 230
    t.integer  "account_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",     limit: 255
  end

  add_index "auxiliaries", ["account_id"], name: "index_auxiliaries_on_account_id", using: :btree

  create_table "bajas", force: :cascade do |t|
    t.integer  "numero",          limit: 4
    t.string   "documento",       limit: 255
    t.date     "fecha"
    t.text     "observacion",     limit: 65535
    t.integer  "user_id",         limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "motivo",          limit: 255
    t.date     "fecha_documento"
    t.integer  "documento_id",    limit: 4
    t.string   "documento_cite",  limit: 255
  end

  add_index "bajas", ["user_id"], name: "index_bajas_on_user_id", using: :btree

  create_table "buildings", force: :cascade do |t|
    t.string   "code",       limit: 50
    t.string   "name",       limit: 230
    t.integer  "entity_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",     limit: 255
  end

  add_index "buildings", ["code"], name: "index_buildings_on_code", unique: true, using: :btree
  add_index "buildings", ["entity_id"], name: "index_buildings_on_entity_id", using: :btree

  create_table "cierre_gestiones", force: :cascade do |t|
    t.decimal  "actualizacion_gestion",           precision: 19, scale: 6
    t.decimal  "depreciacion_gestion",            precision: 19, scale: 6
    t.decimal  "indice_ufv",                      precision: 6,  scale: 5
    t.integer  "asset_id",              limit: 4
    t.integer  "gestion_id",            limit: 4
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.date     "fecha"
  end

  add_index "cierre_gestiones", ["asset_id"], name: "index_cierre_gestiones_on_asset_id", using: :btree
  add_index "cierre_gestiones", ["gestion_id"], name: "index_cierre_gestiones_on_gestion_id", using: :btree

  create_table "departments", force: :cascade do |t|
    t.integer  "code",        limit: 4
    t.string   "name",        limit: 230
    t.string   "status",      limit: 2
    t.integer  "building_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "departments", ["building_id"], name: "index_departments_on_building_id", using: :btree

  create_table "entities", force: :cascade do |t|
    t.string   "code",       limit: 50
    t.string   "name",       limit: 230
    t.string   "acronym",    limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "header",     limit: 255
    t.string   "footer",     limit: 255
  end

  create_table "entradas_salidas", id: false, force: :cascade do |t|
    t.integer  "id",                  limit: 4,                            default: 0,  null: false
    t.integer  "subarticle_id",       limit: 4
    t.datetime "fecha"
    t.string   "factura",             limit: 255
    t.date     "nota_entrega"
    t.string   "nro_pedido",          limit: 11
    t.string   "detalle",             limit: 463
    t.decimal  "cantidad",                        precision: 12, scale: 4
    t.decimal  "costo_unitario",                  precision: 10, scale: 4
    t.integer  "modelo_id",           limit: 4
    t.string   "tipo",                limit: 7,                            default: "", null: false
    t.datetime "created_at"
    t.string   "cite_ems_plantillas", limit: 255
  end

  create_table "entry_subarticles", force: :cascade do |t|
    t.decimal  "amount",                    precision: 10, scale: 4
    t.decimal  "unit_cost",                 precision: 10, scale: 4
    t.decimal  "total_cost",                precision: 10, scale: 2
    t.string   "invoice",       limit: 255,                          default: ""
    t.date     "date"
    t.integer  "subarticle_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "stock",         limit: 4,                            default: 0,     null: false
    t.integer  "note_entry_id", limit: 4
    t.boolean  "invalidate",                                         default: false
  end

  add_index "entry_subarticles", ["note_entry_id"], name: "fk_rails_ee711e9361", using: :btree
  add_index "entry_subarticles", ["subarticle_id"], name: "index_entry_subarticles_on_subarticle_id", using: :btree

  create_table "gestiones", force: :cascade do |t|
    t.string   "anio",         limit: 255, default: "",    null: false
    t.boolean  "cerrado",                  default: false, null: false
    t.datetime "fecha_cierre"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "user_id",      limit: 4
  end

  add_index "gestiones", ["user_id"], name: "index_gestiones_on_user_id", using: :btree

  create_table "ingresos", force: :cascade do |t|
    t.integer  "numero",                limit: 4
    t.date     "nota_entrega_fecha"
    t.string   "factura_numero",        limit: 255
    t.string   "factura_autorizacion",  limit: 255
    t.date     "factura_fecha"
    t.integer  "supplier_id",           limit: 4
    t.string   "c31_numero",            limit: 255
    t.boolean  "baja_logica",                                                default: false
    t.decimal  "total",                             precision: 10, scale: 2
    t.datetime "created_at",                                                                 null: false
    t.datetime "updated_at",                                                                 null: false
    t.string   "nota_entrega_numero",   limit: 255
    t.date     "c31_fecha"
    t.integer  "user_id",               limit: 4
    t.string   "incremento_alfabetico", limit: 255
    t.string   "observacion",           limit: 255
    t.integer  "documento_id",          limit: 4
    t.string   "documento_cite",        limit: 255
    t.string   "tipo_ingreso",          limit: 255
    t.string   "entidad_donante",       limit: 255
  end

  add_index "ingresos", ["supplier_id"], name: "index_ingresos_on_supplier_id", using: :btree
  add_index "ingresos", ["user_id"], name: "index_ingresos_on_user_id", using: :btree

  create_table "materials", force: :cascade do |t|
    t.string   "code",        limit: 50
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",      limit: 2
  end

  create_table "note_entries", force: :cascade do |t|
    t.string   "delivery_note_number",  limit: 255
    t.date     "delivery_note_date"
    t.string   "invoice_number",        limit: 255,                            default: ""
    t.date     "invoice_date"
    t.integer  "supplier_id",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "total",                               precision: 10, scale: 2
    t.integer  "user_id",               limit: 4
    t.date     "note_entry_date"
    t.boolean  "invalidate",                                                   default: false
    t.string   "message",               limit: 255
    t.string   "invoice_autorizacion",  limit: 255
    t.string   "c31",                   limit: 255
    t.integer  "nro_nota_ingreso",      limit: 4,                              default: 0
    t.decimal  "subtotal",                            precision: 10, scale: 2, default: 0.0
    t.decimal  "descuento",                           precision: 10, scale: 2, default: 0.0
    t.string   "incremento_alfabetico", limit: 255
    t.string   "observacion",           limit: 255
    t.date     "c31_fecha"
    t.boolean  "reingreso",                                                    default: false, null: false
    t.integer  "documento_id",          limit: 4
    t.text     "json_usuarios",         limit: 65535
    t.string   "documento_cite",        limit: 255
    t.string   "tipo_ingreso",          limit: 255
    t.string   "entidad_donante",       limit: 255
  end

  add_index "note_entries", ["supplier_id"], name: "index_note_entries_on_supplier_id", using: :btree
  add_index "note_entries", ["user_id"], name: "fk_rails_ad8862a094", using: :btree

  create_table "proceedings", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.integer  "admin_id",        limit: 4
    t.string   "proceeding_type", limit: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "fecha"
    t.boolean  "baja_logica",                   default: false,     null: false
    t.string   "observaciones",   limit: 255,   default: "Ninguno"
    t.text     "usuario_info",    limit: 65535
    t.string   "plantillas_info", limit: 255
  end

  add_index "proceedings", ["admin_id"], name: "index_proceedings_on_admin_id", using: :btree
  add_index "proceedings", ["user_id"], name: "index_proceedings_on_user_id", using: :btree

  create_table "requests", force: :cascade do |t|
    t.integer  "admin_id",              limit: 4
    t.integer  "user_id",               limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",                limit: 255,   default: "0"
    t.datetime "delivery_date"
    t.boolean  "invalidate",                          default: false
    t.string   "message",               limit: 255
    t.integer  "nro_solicitud",         limit: 4,     default: 0
    t.string   "incremento_alfabetico", limit: 255
    t.string   "observacion",           limit: 255
    t.integer  "documento_id",          limit: 4
    t.text     "json_usuarios",         limit: 65535
    t.string   "cite_sms",              limit: 255
    t.string   "cite_ems",              limit: 255
  end

  add_index "requests", ["admin_id"], name: "fk_rails_c38a214881", using: :btree
  add_index "requests", ["user_id"], name: "fk_rails_8ead8b1e6b", using: :btree

  create_table "resumen", id: false, force: :cascade do |t|
    t.integer "id",               limit: 4,                          default: 0,     null: false
    t.integer "subarticle_id",    limit: 4
    t.integer "request_id",       limit: 4
    t.decimal "amount",                     precision: 10, scale: 2
    t.decimal "amount_delivered",           precision: 10, scale: 2
    t.decimal "total_delivered",            precision: 10, scale: 2
    t.boolean "invalidate",                                          default: false
    t.integer "code",             limit: 4
    t.decimal "monto1",                     precision: 10, scale: 4
    t.integer "stock",            limit: 4,                          default: 0,     null: false
    t.decimal "monto2",                     precision: 10, scale: 2
  end

  create_table "seguros", force: :cascade do |t|
    t.integer  "supplier_id",           limit: 4
    t.integer  "user_id",               limit: 4
    t.string   "numero_poliza",         limit: 255
    t.string   "numero_contrato",       limit: 255
    t.string   "factura_numero",        limit: 255
    t.string   "factura_autorizacion",  limit: 255
    t.date     "factura_fecha"
    t.float    "factura_monto",         limit: 53
    t.datetime "fecha_inicio_vigencia"
    t.datetime "fecha_fin_vigencia"
    t.boolean  "baja_logica",                       default: false
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "seguro_id",             limit: 4
    t.string   "state",                 limit: 255
    t.string   "tipo",                  limit: 255
  end

  add_index "seguros", ["seguro_id"], name: "index_seguros_on_seguro_id", using: :btree
  add_index "seguros", ["supplier_id"], name: "fk_rails_7cf708c516", using: :btree
  add_index "seguros", ["user_id"], name: "fk_rails_fbfcdaa8db", using: :btree

  create_table "subarticle_requests", force: :cascade do |t|
    t.integer "subarticle_id",    limit: 4
    t.integer "request_id",       limit: 4
    t.decimal "amount",                     precision: 10, scale: 2
    t.decimal "amount_delivered",           precision: 10, scale: 2
    t.decimal "total_delivered",            precision: 10, scale: 2
    t.boolean "invalidate",                                          default: false
  end

  add_index "subarticle_requests", ["request_id"], name: "index_subarticle_requests_on_request_id", using: :btree
  add_index "subarticle_requests", ["subarticle_id"], name: "index_subarticle_requests_on_subarticle_id", using: :btree

  create_table "subarticles", force: :cascade do |t|
    t.integer  "code",        limit: 4
    t.string   "description", limit: 255
    t.string   "unit",        limit: 255
    t.string   "status",      limit: 255
    t.integer  "article_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "amount",      limit: 4
    t.integer  "minimum",     limit: 4
    t.string   "barcode",     limit: 255
    t.string   "code_old",    limit: 255
    t.integer  "incremento",  limit: 4
    t.integer  "material_id", limit: 4
  end

  add_index "subarticles", ["article_id"], name: "index_subarticles_on_article_id", using: :btree
  add_index "subarticles", ["material_id"], name: "index_subarticles_on_material_id", using: :btree

  create_table "suppliers", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nit",        limit: 255
    t.string   "telefono",   limit: 255
    t.string   "contacto",   limit: 255
  end

  create_table "ubicaciones", force: :cascade do |t|
    t.string   "abreviacion", limit: 255
    t.string   "descripcion", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "ufvs", force: :cascade do |t|
    t.date     "fecha"
    t.decimal  "valor",      precision: 7, scale: 5, default: 0.0, null: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username",               limit: 230, default: "",    null: false
    t.integer  "code",                   limit: 4
    t.string   "name",                   limit: 230
    t.string   "title",                  limit: 230
    t.string   "ci",                     limit: 255
    t.string   "phone",                  limit: 230
    t.string   "mobile",                 limit: 230
    t.string   "status",                 limit: 2
    t.integer  "department_id",          limit: 4
    t.string   "role",                   limit: 255
    t.boolean  "password_change",                    default: false, null: false
    t.integer  "assets_count",           limit: 4,   default: 0
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",    limit: 255,                  null: false
    t.integer  "item_id",      limit: 4
    t.string   "event",        limit: 255,                  null: false
    t.string   "whodunnit",    limit: 255
    t.text     "object",       limit: 65535
    t.datetime "created_at"
    t.boolean  "active",                     default: true
    t.string   "item_spanish", limit: 255
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  add_foreign_key "asset_proceedings", "assets"
  add_foreign_key "asset_proceedings", "proceedings"
  add_foreign_key "assets", "auxiliaries"
  add_foreign_key "assets", "bajas"
  add_foreign_key "assets", "ingresos"
  add_foreign_key "assets", "ubicaciones"
  add_foreign_key "assets", "users"
  add_foreign_key "assets_seguros", "assets"
  add_foreign_key "assets_seguros", "seguros"
  add_foreign_key "auxiliaries", "accounts"
  add_foreign_key "bajas", "users"
  add_foreign_key "buildings", "entities"
  add_foreign_key "cierre_gestiones", "assets"
  add_foreign_key "cierre_gestiones", "gestiones"
  add_foreign_key "departments", "buildings"
  add_foreign_key "entry_subarticles", "note_entries"
  add_foreign_key "entry_subarticles", "subarticles"
  add_foreign_key "gestiones", "users"
  add_foreign_key "ingresos", "suppliers"
  add_foreign_key "ingresos", "users"
  add_foreign_key "note_entries", "suppliers"
  add_foreign_key "note_entries", "users"
  add_foreign_key "proceedings", "users"
  add_foreign_key "proceedings", "users", column: "admin_id"
  add_foreign_key "requests", "users"
  add_foreign_key "requests", "users", column: "admin_id"
  add_foreign_key "seguros", "seguros"
  add_foreign_key "seguros", "suppliers"
  add_foreign_key "seguros", "users"
  add_foreign_key "subarticle_requests", "requests"
  add_foreign_key "subarticle_requests", "subarticles"
  add_foreign_key "subarticles", "materials"
end
