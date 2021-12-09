class SeguroFormulario extends React.Component {
  constructor(props) {
    super(props);
    this.capturaDatos = this.capturaDatos.bind(this);
    this.capturaProveedor = this.capturaProveedor.bind(this);
    this.state = {
      proveedor: {}
    }
  }

  capturaProveedor(proveedor) {
    this.setState({ proveedor: proveedor });
    $('#nit').val(proveedor.nit);
    $('#telefono').val(proveedor.telefono);
    this.capturaDatos();
  }

  capturaDatos() {
    this.props.capturarDatos({
      supplier_id: this.state.proveedor ? this.state.proveedor.id : '',
      factura_numero: this.refs.factura_numero ? this.refs.factura_numero.value : '',
      factura_autorizacion: this.refs.factura_autorizacion ? this.refs.factura_autorizacion.value : '',
      factura_monto: this.refs.factura_monto ? this.refs.factura_monto.value : '',
      factura_fecha: this.refs.factura_fecha ? this.refs.factura_fecha.refs.datepicker.value : '',
      tipo: this.refs.tipo ? this.refs.tipo.value : '',
      numero_poliza: this.refs.numero_poliza ? this.refs.numero_poliza.value : '',
      numero_contrato: this.refs.numero_contrato ? this.refs.numero_contrato.value : '',
      fecha_inicio_vigencia: this.refs.fecha_inicio_vigencia ? this.refs.fecha_inicio_vigencia.refs.datepicker.value : '' ,
      fecha_fin_vigencia: this.refs.fecha_fin_vigencia ? this.refs.fecha_fin_vigencia.refs.datepicker.value : ''
    });
  }

  render() {
    if (this.props.seguro_id) {
      return (
        <div className='form-horizontal' role='form'>
          <div className='form-group'>
            <label className='col-sm-2 control-label'>Factura</label>
            <div className='col-sm-2'>
              <input type='text' ref='factura_numero' name='factura_numero' className='form-control' placeholder='Número de factura' autoComplete='off' onChange={this.capturaDatos} />
            </div>
            <div className='col-sm-2'>
              <input type='text' ref='factura_autorizacion' name='factura_autorizacion' className='form-control' placeholder='Número autorización' autoComplete='off' onChange={this.capturaDatos} />
            </div>
            <div className='col-sm-2'>
              <input type='text' ref='factura_monto' name='factura_monto' className='form-control' placeholder='Monto' autoComplete='off' onChange={this.capturaDatos} />
            </div>
            <div className='col-sm-2'>
              <div className='input-group'>
                <DatePicker ref='factura_fecha' id='factura_fecha' placeholder='Fecha de factura' classname='form-control' captura_fecha={this.capturaDatos}/>
                <div className='input-group-addon'>
                  <span className='glyphicon glyphicon-calendar'></span>
                </div>
              </div>
            </div>
          </div>
          <div className='form-group'>
            <label className='col-sm-2 control-label'>Contrato</label>
            <div className='col-sm-2'>
              <input type='text' ref='numero_contrato' name='numero_contrato' className='form-control' placeholder='Número de contrato' autoComplete='off' value={this.props.numero_contrato} readOnly />
            </div>
          </div>
        </div>);
    }
    else {
      return (
        <div className='form-horizontal' role='form'>
          <div className='form-group'>
            <label className='col-sm-2 control-label'>Proveedor</label>
            <div className='col-sm-4'>
              <AutoCompleteProveedor urls={this.props.urls} capturarProveedor={this.capturaProveedor} proveedor={this.props.proveedor} />
            </div>
            <div className='col-sm-2'>
              <input type='text' id='nit' className='form-control' placeholder='NIT proveedor' disabled='disabled' />
            </div>
            <div className='col-sm-2'>
              <input type='text' id='telefono' className='form-control' placeholder='Teléfonos proveedor' disabled='disabled' />
            </div>
          </div>
          <div className='form-group'>
            <label className='col-sm-2 control-label'>Factura</label>
            <div className='col-sm-2'>
              <input type='text' ref='factura_numero' name='factura_numero' className='form-control' placeholder='Número de factura' autoComplete='off' onChange={this.capturaDatos} />
            </div>
            <div className='col-sm-2'>
              <input type='text' ref='factura_autorizacion' name='factura_autorizacion' className='form-control' placeholder='Número autorización' autoComplete='off' onChange={this.capturaDatos} />
            </div>
            <div className='col-sm-2'>
              <input type='text' ref='factura_monto' name='factura_monto' className='form-control' placeholder='Monto' autoComplete='off' onChange={this.capturaDatos} />
            </div>
            <div className='col-sm-2'>
              <div className='input-group'>
                <DatePicker ref='factura_fecha' id='factura_fecha' placeholder='Fecha de factura' classname='form-control' captura_fecha={this.capturaDatos}/>
                <div className='input-group-addon'>
                  <span className='glyphicon glyphicon-calendar'></span>
                </div>
              </div>
            </div>
          </div>
          <div className='form-group'>
            <label className='col-sm-2 control-label'>Póliza</label>
            <div className='col-sm-4'>
              <input type='text' ref='tipo' name='tipo' className='form-control' placeholder='Tipo de Póliza' autoComplete='off' onChange={this.capturaDatos} />
            </div>
            <div className='col-sm-2'>
              <input type='text' ref='numero_poliza' name='numero_poliza' className='form-control' placeholder='Póliza' autoComplete='off' onChange={this.capturaDatos} />
            </div>
            <div className='col-sm-2'>
              <input type='text' ref='numero_contrato' name='numero_contrato' className='form-control' placeholder='Número de contrato' autoComplete='off' onChange={this.capturaDatos} />
            </div>
          </div>
          <div className='form-group'>
            <label className='col-sm-2 control-label'>Vigencia de la Póliza</label>
            <div className='col-sm-2'>
              <div className='input-group'>
                <DateTimePicker ref='fecha_inicio_vigencia'  id='fecha_inicio_vigencia' placeholder={'Fecha inicio de vigencia'} classname='form-control' captura_fecha={this.capturaDatos} />
                <div className='input-group-addon'>
                  <span className='glyphicon glyphicon-calendar'></span>
                </div>
              </div>
            </div>
            <div className='col-sm-2'>
              <div className='input-group'>
                <DateTimePicker ref='fecha_fin_vigencia' id='fecha_fin_vigencia' placeholder={'Fecha fin de vigencia'} classname='form-control' captura_fecha={this.capturaDatos}/>
                <div className='input-group-addon'>
                  <span className='glyphicon glyphicon-calendar'></span>
                </div>
              </div>
            </div>
          </div>
        </div>);
    }
  }
}
