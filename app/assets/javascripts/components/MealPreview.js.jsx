class MealPreview extends React.Component {
  handleEditMeal() {
    window.location.assign('/#/users/' + this.props.meal.user.id + '/meals/' + this.props.meal.id + '/edit');
  }

  render() {
    return (
      <div className="meal-preview col-md-5">
        <div className="description">
          <div className="pull-left"><h4>{this.props.meal.description}</h4></div>
          <button type="button" className="btn btn-default btn-sm pull-right" onClick={this.handleEditMeal.bind(this)}>
            <span className="glyphicon glyphicon-cog" aria-hidden="true"></span>
          </button>
          <div className="clearfix"></div>
        </div>
        <div className="attrs text-center">
          <div className="time col-md-6">
            <div><strong>Time</strong></div>
            <span className="value">{this.props.meal.time}</span>
          </div>
          <div className="calories col-md-6">
            <div><strong>Calories</strong></div>
            <span className="value">{this.props.meal.calories}</span>
          </div>
        </div>
      </div>
    );
  }
};