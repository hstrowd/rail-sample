class MealForm extends React.Component {
  constructor(props) {
    super(props);

    var currentDate = new Date();
    this.state = {
      userID: (this.props.userID || ''),
      description: (this.props.meal.description || ''),
      calories: (this.props.meal.calories || ''),
      date: (moment(this.props.meal.occurred_at).format(MealForm.DATE_FORMAT) ||
             moment().format(MealForm.DATE_FORMAT)),
      time: (moment(this.props.meal.occurred_at).format(MealForm.TIME_FORMAT) ||
             moment().format(MealForm.TIME_FORMAT))
    };
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.meal != this.props.meal) {
      this.setState({
        description: (nextProps.meal.description || ''),
        calories: (nextProps.meal.calories || ''),
        date: (moment(nextProps.meal.occurred_at).format(MealForm.DATE_FORMAT) ||
               moment().format(MealForm.DATE_FORMAT)),
        time: (moment(nextProps.meal.occurred_at).format(MealForm.TIME_FORMAT) ||
               moment().format(MealForm.TIME_FORMAT))
      });
    }
  }

  formatDate(date) {
    return date.getFullYear() + '-' + date.getMonth() + '-' + date.getDate();
  }
  formatTime(date) {
    return date.getHours() + ':' + date.getMinutes() + ':' + date.getSeconds();
  }

  updateDescription(event) {
    this.setState({ description: event.target.value });
  }
  updateCalories(event) {
    this.setState({ calories: event.target.value });
  }
  updateDate(event) {
    this.setState({ date: event.target.value });
  }
  updateTime(event) {
    this.setState({ time: event.target.value });
  }

  handleSubmit(event) {
    event.preventDefault();
    this.props.handleFormSubmit(this.state)
  }

  render() {
    return (
      <form onSubmit={this.handleSubmit.bind(this)}>
        <div className="form-group">
          <label>Description</label>
          <input type="text"
                 name="description"
                 className="form-control"
                 placeholder="Describe this meal"
                 required={true}
                 value={this.state.description}
                 onChange={this.updateDescription.bind(this)} />
        </div>
        <div className="form-group">
          <label>Calories</label>
          <input type="number"
                 name="calories"
                 className="form-control"
                 placeholder="500"
                 required={true}
                 step="1"
                 min="0"
                 max="2999"
                 value={this.state.calories}
                 onChange={this.updateCalories.bind(this)} />
        </div>
        <div className="form-group">
          <label>Date</label>
          <input type="date"
                 name="date"
                 className="form-control"
                 required={true}
                 value={this.state.date}
                 onChange={this.updateDate.bind(this)} />
        </div>
        <div className="form-group">
          <label>Time</label>
          <input type="time"
                 name="time"
                 className="form-control"
                 required={true}
                 value={this.state.time}
                 onChange={this.updateTime.bind(this)} />
        </div>
        <div className="actions">
          <input type="submit"
                 className="btn btn-success"
                 value={this.props.submitAction} />
        </div>
      </form>
    );
  }
};

MealForm.DATE_FORMAT = 'YYYY-MM-DD';
MealForm.TIME_FORMAT = 'HH:mm';
