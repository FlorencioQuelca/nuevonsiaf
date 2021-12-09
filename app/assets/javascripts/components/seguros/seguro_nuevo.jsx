class SeguroNuevo extends React.Component {
  constructor(props) {
    super(props);
    this.capturaActivos = this.capturaActivos.bind(this);
    this.guardarDatos = this.guardarDatos.bind(this);
    this.state={
      activos: [],
      sumatoria: 0,
      resumen: [],
      sumatoria_resumen: 0
    };
  }

  capturaActivos(activos, sumatoria, resumen, sumatoria_resumen){
    this.setState({
        activos: activos,
        sumatoria: sumatoria,
        resumen: resumen,
        sumatoria_resumen: sumatoria_resumen
    });
  }

  jsonGuardar(){
    let seguro = {};
    seguro = {
      asset_ids: this.state.activos.map(function(e) {
        return e.id;
      })
    };
    if(this.props.data.seguro){
      seguro = $.extend({}, seguro, {seguro_id: this.props.data.seguro.id});
    }
    return(seguro);
  }

  guardarDatos(e){
    let alert = new Notices({ ele: 'div.main' });
    let url = this.props.data.urls.seguros;
    _ = this;
    if(this.state.activos.length > 0){
      $.ajax({
        url: url,
        type: 'POST',
        dataType: 'JSON',
        data: {
          seguro: this.jsonGuardar()
        }
      }).done(function(seguro) {
        alert.success("Se guardó correctamente la cotización.");
        const id = _.props.data.seguro ? _.props.data.seguro.id : seguro.id;
        return window.location = _.props.data.urls.listado_seguros + "/" + id;
      }).fail(function(xhr, status) {
        alert.danger("Error al guardar la cotización.");
      });
    }
    else{
      alert.danger("Error al guardar la cotización.");
    }
  }

  render() {
    return(
      <div>
        <div className="row">
          <div className="col-md-12">
            <h3 className="text-center">
              {this.props.data.titulo}
            </h3>
          </div>
          <BusquedaActivos id="barcode_activos" seguro={this.props.data.seguro} capturaActivos={this.capturaActivos} urls={this.props.data.urls} />
        </div>
        <SeguroTablaActivos activos={this.state.activos} sumatoria={this.state.sumatoria} resumen={this.state.resumen} sumatoria_resumen={this.state.sumatoria_resumen} links_descarga="NO"/>
        <div className="row">
          <div className="action-buttons col-md-12 col-sm-12 text-center">
            <a className="btn btn-danger cancelar-btn" href={this.props.data.urls.listado_seguros}>
              <span className="glyphicon glyphicon-ban-circle"></span>
              Cancelar
            </a>
            &nbsp;
            <button name="button" type="submit" className="btn btn-primary guardar-btn" data-disable-with="Guardando..." onClick={this.guardarDatos}>
              <span className="glyphicon glyphicon-floppy-save"></span>
              Cotizar
            </button>
          </div>
        </div>
      </div>
    );
  }
}
