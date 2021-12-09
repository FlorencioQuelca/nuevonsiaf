class SupplierDespliega extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      supplier: {
        id: '',
        name: '',
        telefono: '',
        contacto: '',
        created_at:'',
        ingresos: [],
        note_entries: []
      }
    }
    this.generarCSVIngresos = this.generarCSVIngresos.bind(this);
    this.generarCSVNoteEntries = this.generarCSVNoteEntries.bind(this);
  }

  generarCSVIngresos() {
    let blob, blobURL, csv;
    csv = '';
    $('table.ingresos > thead').find('tr').each(function() {
      return csv = ';Empresa;Encargado;Nro. de Factura;Nro. Nota de Ingreso;Fecha Nota de Ingreso\n';
    });
    $('table.ingresos > tbody').find('tr').each(function() {
      var sep;
      sep='';
      $(this).find('td').each(function() {
        if($(this).find('a').length > 0) {
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
    return $('.csvingreso').attr('href', blobURL).attr('download', 'data.csv');
  }

  generarCSVNoteEntries() {
    let blob, blobURL, csv;
    csv = '';
    $('table.notes > thead').find('tr').each(function() {
      return csv = ';Empresa;Encargado;Nro. de Factura;Nro. Nota de Ingreso;Fecha Nota de Ingreso\n';
    });
    $('table.notes > tbody').find('tr').each(function() {
      var sep;
      sep='';
      $(this).find('td').each(function() {
        if($(this).find('a').length > 0) {
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
    return $('.csvnote').attr('href', blobURL).attr('download', 'data.csv');
  }

  componentDidUpdate() {
    this.generarCSVIngresos();
    this.generarCSVNoteEntries();
  }

  componentWillMount() {
    $.getJSON(this.props.data.urls.show, (response) => {
      this.setState({ supplier: response })
    });
  }

  render() {
    let cantidadNotes = 0;
    let notes = [];
    let cantidadIngresos = 0;
    let ingresos = [];
    let notesRender = '';
    let ingresosRender = '';
    if(this.state.supplier.note_entries.length > 0)
    {
      notes = this.state.supplier.note_entries.map((note, i)=> {
        return (
          <Note  key = { i + 1 }
                 indice = { i + 1 }
                 note = {note} />
        )
      });
      cantidadNotes = this.state.supplier.note_entries.length;
      notesRender =
        <div>
          <div className="pull-right">
            Descargar:
            <div className="btn-group btn-group-xs">
              <a className="btn btn-default csvnote">CSV</a>
              <a className="btn btn-default pfd" href={this.props.data.urls.pdf_note_entry}>PDF</a>
            </div>
          </div>
          <h3>Notas de Ingreso de Almacenes</h3>
          <table className ="table table-striped table-condensed table-bordered alineacion-media notes">
            <thead>
              <tr>
                  <th className="text-center">
                  <strong className="badge" title="Total">
                    {cantidadNotes}
                  </strong>
                </th>
                <th>Empresa</th>
                <th>Encargado</th>
                <th className='text-center'>Nro. de Factura</th>
                <th className='text-center'>Nro. Nota de Ingreso</th>
                <th className='text-center'>Fecha Nota de Ingreso</th>
              </tr>
            </thead>
            <tbody>
              {notes}
            </tbody>
          </table>
        </div>
    }

    if(this.state.supplier.ingresos.length > 0)
    {
      ingresos = this.state.supplier.ingresos.map((ingreso ,i) =>{
        return (
          <Ingreso  key = { i + 1 }
                    ingreso = {ingreso}
                    indice = { i + 1 }
                    />
        )
      });
      cantidadIngresos = this.state.supplier.ingresos.length;
      ingresosRender =
        <div>
          <div className="pull-right">
            Descargar:
            <div className="btn-group btn-group-xs">
              <a className="btn btn-default csvingreso">CSV</a>
              <a className="btn btn-default pfd" href={this.props.data.urls.pdf_ingreso}>PDF</a>
            </div>
          </div>
          <h3>Notas de Ingreso de Activos Fijos</h3>
          <table className ="table table-striped table-condensed table-bordered alineacion-media ingresos">
            <thead>
              <tr>
                  <th className="text-center">
                  <strong className="badge" title="Total">
                    {cantidadIngresos}
                  </strong>
                </th>
                <th>Empresa</th>
                <th>Encargado</th>
                <th className='text-center'>Nro. de Factura</th>
                <th className='text-center'>Nro. Nota de Ingreso</th>
                <th className='text-center'>Fecha Nota de Ingreso</th>
              </tr>
            </thead>
            <tbody>
              {ingresos}
            </tbody>
          </table>
        </div>
    }

    return (
        <div>
          <div className="page-header">
            <div className="pull-right">
              <a className="btn btn-primary" href={this.props.data.urls.edit}>
                <span className="glyphicon glyphicon-edit"></span>
                 Editar
              </a>
              &nbsp;
              <a className="btn btn-default" href={this.props.data.urls.list}>
                <spam className="glyphicon glyphicon-list"></spam>
                 Proveedores
             </a>
            </div>
            <h2>Proveedor</h2>
          </div>
          <div className="col-lg-4 col-md-5 col-sm-12">
            <dl className="dl-horizontal">
              <dt>Nombre</dt>
              <dd>{this.state.supplier.name}</dd>
              <dt>NIT</dt>
              <dd>{this.state.supplier.nit}</dd>
              <dt>Teléfono</dt>
              <dd>{this.state.supplier.telefono}</dd>
              <dt>Contacto</dt>
              <dd>{this.state.supplier.contacto}</dd>
              <dt>Fecha de creación</dt>
              <dd>{this.state.supplier.created_at}</dd>
            </dl>
          </div>
          <div className="col-lg-8 col-md-7 col-sm-12" id="current-supplier">
            {notesRender}
            {ingresosRender}
          </div>
      </div>
    );
  }
}
