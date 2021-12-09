var Acta = React.createClass({
    render() {
        var indice= this.props.indice;
        var fecha= this.props.acta.obt_fecha;
        var tipo= this.props.acta.tipo_acta;
        var activos = this.props.acta.assets.map((activo, i) => {
          return (
            <Activo key = { i+1 }
                    indice = { i+1 }
                    activo = { activo }/>
          )
        });
        return (
          <div>
          <h3> {tipo} {fecha} </h3>
          <table className="table table-striped table-condensed table-bordered alineacion-media">
          <thead>
            <tr>
              <th></th>
              <th>Descripción</th>
              <th>Código</th>
            </tr>
          </thead>
          <tbody>
            { activos }
          </tbody>
          </table>
        </div>
        )
    }
});

var ActivosHistorico = React.createClass({
  getInitialState() {
    return { actas: [] }
  },

  componentDidMount() {
    $.getJSON(this.props.usuario.urls.historico, (response) => {
      this.setState({ actas: response }) });
  },

  render() {
    var listado_actas = this.state.actas.map((acta, i) => {
      return (
        <Acta key = { i + 1 }
              indice = { i + 1 }
              acta = { acta }/>
      )
    });
    if(listado_actas.length > 0){
      return (
        <div className="col-lg-8 col-md-7 col-sm-12" id="current-assets">
          <h4>Histórico Activos Fijos Asignados</h4>
          <div className="table-responsive col-md-6">
            { listado_actas }
          </div>
        </div>
      );
    }
    else{
      return(
        <div className="col-lg-8 col-md-7 col-sm-12" id="historical-assets">
          <div className="alert alert-info alert-dismissable">
            <button aria-hidden="true" className="close" data-dismiss="alert" type="button">&times;</button>
            No tiene histórico de activos que le fueron asignados.
          </div>
        </div>
      );
    }
  }
});

var DatosUsuario = React.createClass({
  render() {
    var codigo = this.props.usuario.code;
    var cargo = this.props.usuario.title;
    var ci = this.props.usuario.ci;
    var email = this.props.usuario.email;
    var nombre_usuario = this.props.usuario.username;
    var telefono = this.props.usuario.phone;
    var celular = this.props.usuario.mobile;
    var unidad = this.props.usuario.department_name;
    var rol = this.props.usuario.role;
    var estado = this.props.usuario.estado;

    return (
      <div className="col-lg-4 col-md-5 col-sm-12">
        <dl className="dl-horizontal">
          {/* <dt>Código</dt>
          <dd>{ codigo }</dd> */}
          <dt>C.I.</dt>
          <dd>{ ci } </dd>
          <dt>Unidad</dt>
          <dd>{ unidad }</dd>
          <dt>Cargo</dt>
          <dd>{ cargo }</dd>
          <dt>Email</dt>
          <dd>{ email }</dd>
          <dt>Usuario</dt>
          <dd>{ nombre_usuario }</dd>
          <dt>Teléfono</dt>
          <dd>{ telefono }</dd>
          <dt>Celular</dt>
          <dd>{ celular }</dd>
          <dt>Rol</dt>
          <dd>{ rol }</dd>
          <dt>Estado</dt>
          <dd>{ estado }</dd>
        </dl>
      </div>
    );
  }
});

var Cabecera = React.createClass({
  manejadorBotonHistorico(){
    this.props.actualizacionBoton("historico");
  },

  manejadorBotonActivos(){
    this.props.actualizacionBoton("activos");
  },

  administrador(){
    if(this.props.admin == '1'){
      return(
        <div className='btn-group' data-toggle='buttons'>
          <label className='btn btn-default' onClick={ this.manejadorBotonHistorico }>
            <input type="radio" name="reports" id="reports_historical" value="historical" />
            <span className='glyphicon glyphicon-list-alt'></span>
            Histórico
          </label>
          <label className='btn btn-default active' onClick={ this.manejadorBotonActivos }>
            <input type="radio" name="reports" id="reports_current" value="current" defaultChecked=""/>
            <span className='glyphicon glyphicon-th-list'></span>
          </label>
        </div>
      )
    } else if (this.props.admin == '0') {
     return(
       <a className="btn btn-info" href={this.props.usuario.urls.historico_almacen}><span className='glyphicon glyphicon-list'></span>
       Histórico Almacenes
       </a>
     )
    }
  },
  render() {
    var nombre_usuario = this.props.usuario.name;

    return (
      <div className='page-header'>
        <div className='pull-right'>
          { this.administrador() }
          &nbsp;
          <a className="btn btn-primary" href={this.props.usuario.urls.edit}><span className='glyphicon glyphicon-edit'></span>
          Editar
          </a>
          &nbsp;
          <a className="btn btn-default" href={this.props.usuario.urls.list}><span className='glyphicon glyphicon-list'></span>
          Funcionarios
          </a>
          &nbsp;
        </div>
        <h2>{ nombre_usuario }</h2>
      </div>
    );
  }
});

var Cuerpo = React.createClass({
  elige_vista: function() {
    if(this.props.admin == 1){
      if(this.props.tipo_vista == "historico"){
        return(<ActivosHistorico usuario = { this.props.usuario }/>);
      }
      else{
        return(<Activos usuario = { this.props.usuario } activos = { this.props.activos }/>);
      }
    }
  },

  render() {
    return (
      <div className='row'>
        <DatosUsuario usuario = { this.props.usuario }/>
        { this.elige_vista() }
      </div>
    );
  }
});

var Funcionarios = React.createClass({
  getInitialState: function() {
      return {
          tipo_vista: "activos"
      };
  },

  manejoBoton(tipo_vista) {
      this.setState({
          tipo_vista: tipo_vista
      });
  },

  render() {
    return (
      <div>
        <Cabecera usuario = {this.props.usuario} admin = {this.props.admin} actualizacionBoton={this.manejoBoton}/>
        <Cuerpo usuario = {this.props.usuario} admin = {this.props.admin} activos = {this.props.activos} tipo_vista = {this.state.tipo_vista}/>
      </div >
    );
  }
});
