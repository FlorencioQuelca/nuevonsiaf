class DateTimePicker extends React.Component {
  constructor(props) {
    super(props);
    this.capturaFecha = this.capturaFecha.bind(this);
    this.state = {
      fecha: this.props.valor || ''
    };
  }

  componentDidMount() {
    $("#" + this.props.id).datetimepicker({
      defaultDate: this.props.valor ? new Date(this.props.valor) : '',
      format: 'DD/MM/YYYY HH:mm',
      locale: 'es'
    });
  }

  capturaFecha(){
    this.setState({
      fecha: this.refs.datepicker.value
    });
    this.props.captura_fecha();
  }

  render(){
    return(
      <input type="text" ref='datepicker' id={this.props.id} className={this.props.classname} placeholder={this.props.placeholder} autoComplete="off" onSelect={this.capturaFecha} onChange={this.capturaFecha} />
    )
  }
}
