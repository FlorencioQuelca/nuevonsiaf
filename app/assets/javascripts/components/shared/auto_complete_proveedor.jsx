class AutoCompleteProveedor extends React.Component {
  constructor(props) {
    super(props);
    this.onSuggestionsFetchRequested = this.onSuggestionsFetchRequested.bind(this);
    this.onSuggestionsClearRequested = this.onSuggestionsClearRequested.bind(this);
    this.getSuggestionValue = this.getSuggestionValue.bind(this);
    this.renderSuggestion = this.renderSuggestion.bind(this);
    this.state = {
      value: this.props.proveedor ? this.props.proveedor.name : '',
      suggestions: []
    };
  }

  escapeRegexCharacters(str) {
    return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  }

  escapeValor(value) {
    return this.escapeRegexCharacters(value.trim());
  }

  onChange(event, { newValue, method }) {
    this.setState({ value: newValue });
  }

  getSuggestionValue(suggestion) {
    this.props.capturarProveedor(suggestion);
    return suggestion.name;
  }

  renderSuggestion(suggestion) {
    return <span>{suggestion.name}</span>;
  }

  onSuggestionsFetchRequested({ value }) {
    this.props.capturarProveedor('');
    escapedValue = this.escapeValor(value);
    if (escapedValue === '') {
      this.setState({
        suggestions: []
      });
    }
    const regex = new RegExp(escapedValue, 'i');
    $.getJSON(this.props.urls.proveedores + '?q=' + escapedValue + '&limit=10', (response) => {
      this.setState({
        suggestions: response.filter(proveedor => regex.test(proveedor.name))
      });
    });
  }

  onSuggestionsClearRequested() {
    this.setState({
      suggestions: []
    });
  }

  render() {
    const { value, suggestions } = this.state;
    const inputProps = {
      id: 'proveedores',
      placeholder: 'Proveedor',
      value,
      onChange: this.onChange.bind(this),
      className: 'form-control'
    };
    return (
        <Autosuggest
          suggestions={suggestions}
          onSuggestionsFetchRequested={this.onSuggestionsFetchRequested}
          onSuggestionsClearRequested={this.onSuggestionsClearRequested}
          getSuggestionValue={this.getSuggestionValue}
          renderSuggestion={this.renderSuggestion}
          inputProps={inputProps} />
    );
  }
}
