class Ingreso extends React.Component{
  constructor(props) {
    super(props);
  }

  render() {
    const indice = this.props.indice;
    const encargado = this.props.ingreso.encargado;
    const empresa = this.props.ingreso.name;
    const factura_numero = this.props.ingreso.factura_numero;
    const nota_entrega_fecha = this.props.ingreso.nota_entrega_fecha;
    const numero = this.props.ingreso.numero;
    const link = this.props.ingreso.urls.show;
    return(
      <tr>
        <td className='text-center'>{indice}</td>
        <td>{empresa}</td>
        <td>{encargado}</td>
        <td className='text-center'>{factura_numero}</td>
        <td className='text-center'><a href={link}>{numero}</a></td>
        <td className='text-center'>{nota_entrega_fecha}</td>
      </tr>
    )
  }
};
