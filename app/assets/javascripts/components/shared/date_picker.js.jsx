class DatePicker extends React.Component {
  constructor(props) {
    super(props);
    this.capturaFecha = this.capturaFecha.bind(this);
    this.state = {
      fecha: this.props.valor|| ''
    };
  }

  componentDidMount() {
    _ = this;
    $("#" + this.props.id).datepicker({
      autoclose: true,
      format: "dd/mm/yyyy",
      language: "es"
    }).on("changeDate",function(){
      _.capturaFecha();
    });
    $("#" + this.props.id).datepicker('setDate', new Date(this.props.valor));
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
