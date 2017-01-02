class MealFilterForm extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      startDate: (this.props.startDate || ''),
      endDate:   (this.props.endDate || ''),
      startHour: (this.props.startHour || ''),
      endHour:   (this.props.endHour || '')
    };
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.filters != this.props.filters) {
      this.setState({
        startDate: (nextProps.filters.startDate || ''),
        endDate:   (nextProps.filters.endDate || ''),
        startHour: (nextProps.filters.startHour || ''),
        endHour:   (nextProps.filters.endHour || '')
      });
    }
  }

  formatDate(date) {
    return date.getFullYear() + '-' + date.getMonth() + '-' + date.getDate();
  }
  formatTime(date) {
    return date.getHours() + ':' + date.getMinutes() + ':' + date.getSeconds();
  }

  updateStartDate(event) {
    this.setState({ startDate: event.target.value });
  }
  updateEndDate(event) {
    this.setState({ endDate: event.target.value });
  }
  updateStartHour(event) {
    this.setState({ startHour: event.target.value });
  }
  updateEndHour(event) {
    this.setState({ endHour: event.target.value });
  }

  handleSubmit(event) {
    event.preventDefault();
    this.props.handleFormSubmit(this.state)
  }

  render() {
    var formStyle = {
      margin: '1rem 0',
      textAlign: 'center'
    };
    var formGroupStyles = {
      display: 'inline-block',
      margin: '0 1rem'
    };
    var formFieldStyles = {
      display: 'inline-block',
      width: '16rem',
      margin: '0 1rem'
    };

    return (
      <form className="filters"
            onSubmit={this.handleSubmit.bind(this)}
            style={formStyle} >
        <div className="form-group"
             style={formGroupStyles} >
          <label>Date Range:</label>
          <input type="date"
                 name="startDate"
                 className="form-control"
                 style={formFieldStyles}
                 value={this.state.startDate}
                 onChange={this.updateStartDate.bind(this)} />
           to
          <input type="date"
                 name="endDate"
                 className="form-control"
                 style={formFieldStyles}
                 value={this.state.endDate}
                 onChange={this.updateEndDate.bind(this)} />
        </div>
        <div className="form-group"
             style={formGroupStyles} >
          <label>Hour Range:</label>
          <input type="number"
                 name="startHour"
                 className="form-control"
                 style={formFieldStyles}
                 step="1"
                 min="0"
                 max="23"
                 value={this.state.startHour}
                 onChange={this.updateStartHour.bind(this)} />
           to
          <input type="number"
                 name="endHour"
                 className="form-control"
                 style={formFieldStyles}
                 step="1"
                 min="0"
                 max="23"
                 value={this.state.endHour}
                 onChange={this.updateEndHour.bind(this)} />
        </div>
        <div className="actions"
             style={formGroupStyles} >
          <input type="submit"
                 className="btn btn-success"
                 value="Filter Meals" />
        </div>
      </form>
    );
  }
};
