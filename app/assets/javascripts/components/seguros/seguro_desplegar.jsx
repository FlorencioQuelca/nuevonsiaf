class SeguroDesplegar extends React.Component {
  constructor(props) {
    super(props);
    this.asegurar = this.asegurar.bind(this);
    this.state = {
      seguro: {},
      activos: [],
      sumatoria: 0,
      resumen: [],
      sumatoria_resumen: 0
    };
  }

  verificaAsegurado(){
    return (this.props.data.seguro.state == "asegurado" ? true : false);
  }

  componentWillMount() {
    this.setState({
      seguro: this.props.data.seguro,
      activos: this.props.data.activos,
      sumatoria: this.props.data.sumatoria,
      resumen: this.props.data.resumen,
      sumatoria_resumen: this.props.data.sumatoria_resumen
    });
  }

  asegurar() {
    window.location = this.props.data.urls.asegurar;
  }

  render() {
    let titulo;
    let boton_incorporar;
    let incorporaciones;
    let name;
    if(this.verificaAsegurado()){
      let poliza = this.props.data.seguro.numero_poliza;
      let tipo = this.props.data.seguro.tipo;
      let fecha_inicio = new Date(this.props.data.seguro.fecha_inicio_vigencia);
      let fecha_fin = new Date(this.props.data.seguro.fecha_fin_vigencia);
      let fecha_factura = new Date(this.props.data.seguro.factura_fecha);
      titulo =
        <div>
          <h2>Póliza: {poliza} desde {moment(fecha_inicio).format("DD/MM/YYYY HH:mm")} hasta {moment(fecha_fin).format("DD/MM/YYYY HH:mm")}</h2>
          <h3>Tipo de Seguro: {tipo}</h3>
        </div>;
      incorporaciones = this.props.data.incorporaciones.map((incorporacion, i) => {
        let name = "panel-" + i;
        return (
          <SeguroPanelActivos key={i} name={name} seguro={incorporacion.seguro} activos={incorporacion.activos} sumatoria={incorporacion.sumatoria} resumen={incorporacion.resumen} sumatoria_resumen={incorporacion.sumatoria_resumen} urls={incorporacion.urls} links_descarga='SI' incorporacion='SI'/>
        )
      });
      boton_incorporar =
        <a className="btn btn-primary" href={this.props.data.urls.incorporaciones}><span className='glyphicon glyphicon-edit'></span>
          Incorporaciones
        </a>;
    }
    else {
      titulo = <h2>Cotización</h2>;
    }
    return(
      <div className="col-md-12">
        <div className='page-header'>
          <div className='pull-right'>
            {boton_incorporar}
            &nbsp;
            <a className="btn btn-default" href={this.props.data.urls.listado_seguros}><span className='glyphicon glyphicon-list'></span>
            Seguros
            </a>
          </div>
          {titulo}
        </div>
        {incorporaciones}
        <br />
        <SeguroPanelActivos name="panel-origen"  seguro={this.props.data.seguro} activos={this.props.data.activos} sumatoria={this.props.data.sumatoria} resumen={this.props.data.resumen} sumatoria_resumen={this.props.data.sumatoria_resumen} urls={this.props.data.urls} links_descarga="SI" />
      </div>
    );
  }
}
