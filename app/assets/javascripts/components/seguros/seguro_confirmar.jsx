class SeguroConfirmar extends React.Component {
  constructor(props) {
    super(props);
    this.state={
      activos:[],
      proveedor:{},
      factura: {},
      contrato: {},
      seguro: {},
      barcode: ''
    };
  }

  getFactura(data){
    return {
      factura_numero: data.factura_numero,
      factura_autorizacion: data.factura_autorizacion,
      factura_fecha: data.factura_fecha
    }
  }

  getContrato(data){
    return {
      numero_contrato: data.numero_contrato,
      fecha_inicio_vigencia: data.fecha_inicio_vigencia,
      fecha_fin_vigencia: data.fecha_fin_vigencia
    }
  }

  componentWillMount(){
    if(this.props.data.seguro){
      this.setState({
        activos: this.props.data.seguro.assets,
        proveedor: this.props.data.seguro.supplier,
        factura: this.getFactura(this.props.data.seguro),
        contrato: this.getContrato(this.props.data.seguro),
        seguro: {},
        barcode: ''
      });
    }
    else{
      this.setState({
        activos: [],
        proveedor: {},
        factura: {},
        contrato: {},
        seguro: {},
        barcode: ''
      });
    }
  }

  render() {
    return(
      <div>
        <div className="row" data-action="seguros">
          <div className="col-md-12">
              <h3 className="text-center">{this.props.data.titulo}</h3>
          </div>
          <BusquedaActivos />
        </div>
        <SeguroTablaActivos
          activos={this.state.activos} />
        <SeguroBotonesAcciones
          urls={this.props.data.urls}
          guardarDatos={this.guardarDatos} />
      </div>
    );
  }
}
