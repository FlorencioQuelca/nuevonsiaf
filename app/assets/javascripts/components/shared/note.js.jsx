class Note extends React.Component{
  constructor(props) {
    super(props);
  }

  render() {
    const indice = this.props.indice;
    const empresa = this.props.note.empresa;
    const encargado = this.props.note.encargado;
    const factura_nro = this.props.note.factura_nro;
    const fecha = this.props.note.fecha;
    const nro = this.props.note.nro_nota_ingreso;
    const link = this.props.note.links.show;

    return(
      <tr>
        <td className='text-center'>{ indice }</td>
        <td>{empresa}</td>
        <td>{encargado}</td>
        <td className='text-center'>{factura_nro}</td>
        <td className='text-center'><a href={link}>{nro}</a></td>
        <td className='text-center'>{fecha}</td>
      </tr>
    )
  }
};
