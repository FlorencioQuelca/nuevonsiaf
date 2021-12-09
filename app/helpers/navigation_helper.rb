module NavigationHelper
  def get_filename(model)
    import_models_filename[import_models.index(model)]
  end

  def import_models
    %w(buildings departments users accounts auxiliaries assets)
  end

  def import_models_filename
    %w(unidadadmin.DBF OFICINA.DBF RESP.DBF CODCONT.DBF auxiliar.DBF ACTUAL.DBF)
  end
end
