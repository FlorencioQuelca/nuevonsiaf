class AuxiliarDespliega extends React.Component {
  constructor(props) {
    super(props);
    this.state ={
      auxiliar: {
        code: '',
        name: '',
        status: '',
        account: {
          id: '',
          name: ''
        },
        assets: []
      }
    };
    this.generarCSV = this.generarCSV.bind(this);
  }

  componentWillMount() {
    $.getJSON(this.props.data.urls.show, (response) => {
      this.setState({ auxiliar: response })
    });
  }

  componentDidUpdate() {
    this.generarCSV();
  }

  generarCSV() {
    let blob, blobURL, csv;
    csv = '';
    $('table > thead').find('tr').each(function() {
      return csv = ';Descripción;Código\n';
    });
    $('table > tbody').find('tr').each(function() {
      var sep;
      sep = '';
      $(this).find('td').each(function() {
        if($(this).find('a').length > 0){
          csv += sep + $(this).find('a')[0].innerHTML;
        }
        else{
          csv += sep + $(this)[0].innerHTML;
        }
        return sep = ';';
      });
      return csv += '\n';
    });
    window.URL = window.URL || window.webkiURL;
    blob = new Blob([csv]);
    blobURL = window.URL.createObjectURL(blob);
    return $('.csv').attr('href', blobURL).attr('download', 'data.csv');
  }

  obtieneEstado() {
    if(this.state.auxiliar.status == 1){
      return 'ACTIVO';
    }
    else if(this.state.auxiliar.status == 1) {
      return 'INACTIVO';
    }
  }

  render() {
    let cantidad = 0;
    let activos = [];
    if(this.state.auxiliar.assets.length > 0){
      activos = this.state.auxiliar.assets.map((activo, i) => {
        return (
          <Activo key = { i + 1 }
                  indice = { i + 1 }
                  activo = { activo }/>
        )
      });
      cantidad = this.state.auxiliar.assets.length;
    }
    return(
      <div>
        <div className='page-header'>
          <div className='pull-right'>
            <a className='btn btn-primary' href={this.props.data.urls.edit}>
              <span className='glyphicon glyphicon-edit'></span>
              Editar
            </a>
            &nbsp;
            <a className='btn btn-default' href={this.props.data.urls.list}>
              <span className='glyphicon glyphicon-list'></span>
              Auxiliares
            </a>
          </div>
          <h2>Auxiliar</h2>
        </div>
        <div className='col-lg-4 col-md-5 col-sm-12'>
          <dl className='dl-horizontal'>
            <dt>Código</dt>
            <dd>{this.state.auxiliar.code}</dd>
            <dt>Nombre</dt>
            <dd>{this.state.auxiliar.name}</dd>
            <dt>Cuenta</dt>
            <dd><a title='15' href={this.props.data.urls.account_url}>{this.state.auxiliar.account.name}</a></dd>
            <dt>Estado</dt>
            <dd>{this.obtieneEstado()}</dd>
          </dl>
        </div>
        <div className='col-lg-8 col-md-7 col-sm-12' id='current-assets'>
          <div className='pull-right'>
            Descargar:
            <div className='btn-group btn-group-xs'>
              <a className='btn btn-default csv'>CSV</a>
              <a className='btn btn-default pdf' href={this.props.data.urls.pdf}>PDF</a>
            </div>
          </div>
          <h4>Activos</h4>
          <table className='table table-striped table-condensed table-bordered alineacion-media'>
            <thead>
              <tr>
                <th className='text-center'>
                  <strong className='badge' title='Total'>
                    {cantidad}
                  </strong>
                </th>
                <th>Descripción</th>
                <th>Código</th>
              </tr>
            </thead>
            <tbody>
              {activos}
            </tbody>
          </table>
        </div>
      </div>
    );
  }
}
