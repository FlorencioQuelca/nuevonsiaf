var Activo = React.createClass({
    render() {
        var indice = this.props.indice;
        var descripcion = this.props.activo.description;
        var codigo = this.props.activo.code;
        var link = this.props.activo.urls.show;
        return (
            <tr>
              <td className='text-center'>{ indice }</td>
              <td>{ descripcion }</td>
              <td className = 'nowrap text-center'>
                <a href = {link}>{codigo}</a>
              </td>
            </tr>
        )
    }
});

var Activos = React.createClass({
  render() {
    var activos = this.props.activos.map((activo, i) => {
      return (
        <Activo key = { i + 1 }
                indice = { i + 1 }
                activo = { activo }/>
      )
    });
    if(activos.length > 0){
      return (
        <div className="col-lg-8 col-md-7 col-sm-12" id="current-assets">
          <div className="pull-right">
            Descargar:
            <div className="btn-group btn-group-xs">
              <button name="button" type="submit" className="download-assets btn btn-default" data-url={ this.props.usuario.urls.download_activos_csv }>CSV</button>
              <button name="button" type="submit" className="download-assets btn btn-default" data-url={ this.props.usuario.urls.download_activos_pdf }>PDF</button>
            </div>
          </div>
          <h4>Activos Fijos Asignados</h4>
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
      );
    }
    else {
      return(
        <div className="col-lg-8 col-md-7 col-sm-12" id="current-assets">
          <div className="alert alert-info alert-dismissable">
            <button aria-hidden="true" className="close" data-dismiss="alert" type="button">&times;</button>
            No tiene activos asignados.
          </div>
        </div>);
    }
  }
});
