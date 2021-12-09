class AccountDespliega extends React.Component {
  constructor(props) {
    super(props);
    this.state={
      account:{
        id: '',
        auxiliares: [],
        activos: [],
        urls: []
     }
   }
    this.generarArchivos= this.generarArchivos.bind(this);
    this.generarCSV= this.generarCSV.bind(this);
 }

  generarArchivos(e) {
      this.generarCSV(e.target.getAttribute('data-type'))
      if(e.target.getAttribute('data-type')=='auxiliar') {
        $('.pdf').attr('href', this.props.data.urls.pdf_auxiliares);
     }
      else{
        $('.pdf').attr('href', this.props.data.urls.pdf_activos);
     }
 }

  generarCSV(tipo) {
    let blob, blobURL, csv;
    csv= '';
    $('table.tabla-'+ tipo + '> thead').find('tr').each(function() {
      let sep= '';
      $(this).find('th').each(function() {
        if($(this).find('bold').length > 0) {
          csv += sep + '';
       }
        else{
          csv += sep + $(this)[0].innerHTML;
       }
        return sep= ';';
     });
      return csv += '\n'
   });
    $('table.tabla-' + tipo + '> tbody').find('tr').each(function() {
      var sep;
      sep= '';
      $(this).find('td').each(function() {
        if($(this).find('strong').length > 0) {
          csv += sep + $(this).find('strong')[0].innerHTML;
       }
        else{
          csv += sep + $(this)[0].innerHTML;
       }
        return sep= ';';
     });
      csv= csv.replace(/<\/?[^>]+(>|$)/g, '');
      return csv += '\n';
   });
    window.URL= window.URL || window.webkiURL;
    blob= new Blob([csv]);
    blobURL= window.URL.createObjectURL(blob);
    return $('.csv').attr('href', blobURL).attr('download', 'data.csv');
 }

  componentWillMount() {
    this.setState ({
      auxiliares: this.props.data.lista_auxiliares,
      activos: this.props.data.lista_activos,
      urls: this.props.data.urls
   });
 }

  componentDidMount() {
    this.generarCSV('auxiliar');
    $('.pdf').attr('href', this.props.data.urls.pdf_auxiliares);
 }


  tabla_auxiliares(cantidad) {
    const auxiliares= this.props.data.lista_auxiliares.map((auxiliar, i)=> {
      return (
        <tr key={auxiliar.id}>
          <td className='text-center'>{i + 1}</td>
          <td className='text-center'><a href={auxiliar.url.show}>{auxiliar.codigo}</a></td>
          <td>{auxiliar.nombre}</td>
          <td className='text-right'>{auxiliar.cantidad_activos}</td>
          <td className='text-right'>{auxiliar.monto_activos}</td>
         </tr>
      )
   });

    return (
      <table className={'table table-bordered table-striped table-hover table-condensed tabla-auxiliar'}>
        <thead>
          <tr>
            <th className='text-center' >
              <bold className='badge' title='Total'>
               {cantidad}
              </bold>
            </th>
            <th className='text-center'>
               <strong>Código</strong>
            </th>
            <th>
              <strong>
                Auxiliar
              </strong>
            </th>
            <th className='text-right'>
              <strong>
                Cantidad Activos
              </strong>
            </th>
            <th className='text-right'>
              <strong>
                Monto Total
              </strong>
            </th>
          </tr>
        </thead>
        <tbody>
        {auxiliares}
          <tr>
            <td colSpan='2'></td>
            <td className='text-right'>
              <strong>
                TOTAL:
              </strong>
            </td>
            <td className='number'>
              <strong>
               {this.props.data.cantidad_activos}
              </strong>
            </td>
            <td className='number'>
              <strong>
               {this.props.data.monto_activos}
              </strong>
            </td>
          </tr>
        </tbody>
      </table>
    );
 }

  tabla_activos(cantidad) {
       const activos= this.props.data.lista_activos.map((activo, i)=>{
        return (
          <tr key= {activo.codigo}>
            <td className='text-center'>{i + 1}</td>
            <td className='text-center'><a href={activo.url.show}> {activo.codigo}</a></td>
            <td>{activo.descripcion}</td>
            <td>{activo.auxiliar}</td>
            <td className='text-right'>{activo.precio}</td>
          </tr>
        )
     });
      return(
        <table className={'table table-bordered table-striped table-hover table-condensed tabla-activo'}>
          <thead>
            <tr>
              <th className='text-center' >
                <bold className='badge' title='Total'>
                 {cantidad}
                </bold>
              </th>
              <th>
                <strong>Código</strong>
              </th>
              <th>
                <strong>
                  Activo
                </strong>
              </th>
              <th>
                <strong>
                  Auxiliar
                </strong>
              </th>
              <th className='text-center'>
                <strong>
                  Precio
                </strong>
              </th>
            </tr>
          </thead>
          <tbody>
             {activos}
              <tr>
                <td colSpan='3'></td>
                <td className='text-right'>
                  <strong>
                    TOTAL:
                  </strong>
                </td>
                <td className='number'>
                  <strong>
                   {this.props.data.monto_activos}
                  </strong>
                </td>
              </tr>
          </tbody>
        </table>
    );
  }

   render() {
    return (
      <div>
        <div className='page-header'>
            <div className='pull-right'>
              <a className='btn btn-default' href={this.props.data.urls.list} >
                <spam className='glyphicon glyphicon-list'></spam>
                 Cuentas
             </a>
            </div>
            <h2>Información de Cuenta</h2>
          </div>
          <div className='col-lg-4 col-md-5 col-sm-12'>
            <dl className='dl-horizontal'>
              <dt>Código</dt>
              <dd>{this.props.data.cuenta.codigo}</dd>
              <dt>Nombre</dt>
              <dd>{this.props.data.cuenta.nombre}</dd>
              <dt>Vida útil</dt>
              <dd>{this.props.data.cuenta.vida_util}</dd>
              <dt>Depreciar</dt>
              <dd>{this.props.data.cuenta.depreciar}</dd>
              <dt>Actualizar</dt>
              <dd>{this.props.data.cuenta.actualizar}</dd>
              <dt>Estado</dt>
              <dd>{this.props.data.cuenta.estado}</dd>
              <dt>Cantidad de Auxiliares</dt>
              <dd>{this.props.data.lista_auxiliares.length}</dd>
            </dl>
          </div>
          <div className='col-lg-8 col-md-7 col-sm-12' id='current-supplier'>
            <div role='tabpanel'>
              <div className='pull-right'>
                <span>Descargar:</span>
                  <div className='btn-group btn-group-xs'>
                  <a className={'btn btn-default csv'}>CSV</a>
                  <a className={'btn btn-default pdf'} href={this.props.data.urls.pdf_auxiliares}>PDF</a>
                </div>
               </div>
            <ul className='nav nav-tabs' role='tablist'>
              <li className='nav-item active'>
                <a href='auxiliares' aria-controls={'auxiliares'} aria-expanded='true'
                className='nav-link active' data-type='auxiliar' data-toggle='tab' href={'#auxiliares'}
                id={'auxiliar-tab'} role='tab' onClick={this.generarArchivos}>Auxiliares</a>
              </li>
              <li>
                <a href='activos' aria-controls={'activos'} aria-expanded='false'
                className='nav-link' data-type='activo' data-toggle='tab' href={'#activos'}
                id={'activos-tab'} role='tab' onClick={this.generarArchivos}>Activos</a>
              </li>
            </ul>
            <div className='tab-content'>
              <div aria-expanded='true' aria-labelledby={'auxiliares-tab'} className='tab-pane fade active in' id={'auxiliares'} role='tabpanel'>
             {this.tabla_auxiliares(this.props.data.lista_auxiliares.length)}
            </div>
            <div aria-expanded='false' aria-labelledby={'activos-tab'} className='tab-pane fade' id={'activos'} role='tabpanel'>
             {this.tabla_activos(this.props.data.cantidad_activos)}
            </div>
            </div>
          </div>
        </div>
      </div>
    )
 }
}
