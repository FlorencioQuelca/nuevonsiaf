class SeguroAsegurar extends React.Component {
  constructor(props) {
    super(props);
    this.guardarDatos = this.guardarDatos.bind(this);
    this.capturarDatos = this.capturarDatos.bind(this);
    this.verificaSeguro = this.verificaSeguro.bind(this);
    this.state={
      seguro: {
        id: this.props.data.seguro.id,
        supplier_id: '',
        factura_numero: '',
        factura_autorizacion: '',
        factura_monto: '',
        factura_fecha: '',
        tipo: '',
        numero_poliza: '',
        numero_contrato: '',
        fecha_inicio_vigencia: '',
        fecha_fin_vigencia: '',
      },
      activos: [],
      sumatoria: 0,
      resumen: [],
      sumatoria_resumen: 0
    };
  }

  escapeRegexCharacters(str) {
    return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
  }

  escapeValor(value){
    let valor = typeof(value) == "undefined" ? '' : value;
    return this.escapeRegexCharacters(valor.trim());
  }

  capturarDatos(data) {
    this.setState({
      seguro: {
        id: this.props.data.seguro.id,
        supplier_id: data.supplier_id,
        factura_numero: data.factura_numero,
        factura_autorizacion: data.factura_autorizacion,
        factura_monto: data.factura_monto,
        factura_fecha: data.factura_fecha,
        tipo: data.tipo,
        numero_poliza: data.numero_poliza,
        numero_contrato: data.numero_contrato,
        fecha_inicio_vigencia: data.fecha_inicio_vigencia,
        fecha_fin_vigencia: data.fecha_fin_vigencia
      }
    });
  }

  verificaSeguro(){
    const supplier_id = this.state.seguro.supplier_id;
    const factura_numero = this.escapeValor(this.state.seguro.factura_numero);
    const factura_autorizacion = this.escapeValor(this.state.seguro.factura_autorizacion);
    const factura_monto = this.escapeValor(this.state.seguro.factura_monto);
    const factura_fecha = this.state.seguro.factura_fecha;
    const tipo = this.escapeValor(this.state.seguro.tipo);
    const numero_poliza = this.escapeValor(this.state.seguro.numero_poliza);
    const numero_contrato = this.escapeValor(this.state.seguro.numero_contrato);
    const fecha_inicio_vigencia = this.state.seguro.fecha_inicio_vigencia;
    const fecha_fin_vigencia = this.state.seguro.fecha_fin_vigencia;
    if(this.props.data.seguro.seguro_id){
      if(factura_numero === '' || factura_autorizacion === '' || factura_fecha === '' ||
         factura_monto === '' || numero_contrato === ''){
        return false;
      }
      else{
        return true;
      }
    }
    else{
      if(supplier_id === '' || factura_numero === '' || factura_autorizacion === '' || factura_fecha === '' ||
         factura_monto === '' || tipo === '' || numero_poliza === '' || numero_contrato === '' ||
         fecha_inicio_vigencia === '' || fecha_fin_vigencia === '') {
        return false;
      }
      else{
        return true;
      }
    }
  }

  componentWillMount(){
    this.setState({
        activos: this.props.data.activos,
        sumatoria: this.props.data.sumatoria,
        resumen: this.props.data.resumen,
        sumatoria_resumen: this.props.data.sumatoria_resumen
    });
  }

  guardarDatos(e){
    const alert = new Notices({ ele: 'div.main' });
    let url = this.props.data.urls.seguros + "/" + this.props.data.seguro.id;
    _ = this;
    if(this.verificaSeguro()){
      $.ajax({
        url: url,
        type: 'PUT',
        dataType: 'JSON',
        data: {
          seguro: this.state.seguro
        }
      }).done(function(seguro) {
        alert.success("Se guardó correctamente el seguro.");
        const id = _.props.data.seguro.seguro_id ? _.props.data.seguro.seguro_id : _.props.data.seguro.id;
        return window.location = _.props.data.urls.listado_seguros + "/" + id;
      }).fail(function(xhr, status) {
        alert.danger("Error al guardar el seguro.");
      });
    }
    else{
      alert.danger("Complete todos los datos requeridos.");
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
          <SeguroFormulario seguro_id={this.props.data.seguro.seguro_id}  urls={this.props.data.urls} capturarDatos={this.capturarDatos} numero_contrato={this.props.data.numero_contrato} />
        </div>
        <SeguroTablaActivos activos={this.state.activos} sumatoria={this.state.sumatoria} resumen={this.state.resumen} sumatoria_resumen={this.state.sumatoria_resumen} />
        <div className="row">
          <div className="action-buttons col-md-12 col-sm-12 text-center">
            <a className="btn btn-danger cancelar-btn" href={this.props.data.urls.listado_seguros}>
              <span className="glyphicon glyphicon-ban-circle"></span>
              Cancelar
            </a>
            &nbsp;
            <button name="button" type="submit" className="btn btn-primary guardar-btn" data-disable-with="Guardando..." onClick={this.guardarDatos}>
              <span className="glyphicon glyphicon-floppy-save"></span>
              Guardar
            </button>
          </div>
        </div>
      </div>
    );
  }
}
