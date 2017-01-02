class UserDetails extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      user: null,
      mealFilters: {}
    };
  }

  componentWillMount() {
    this.retrieveUser(this.props.userID);
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.userID != this.props.userID) {
      this.retrieveUser(nextProps.userID);
    }
    if (nextProps.mealFilters != this.props.mealFilters) {
      this.setState({ mealFilters: nextProps.mealFilters });
    }
  }

  retrieveUser(userID) {
    var self = this;
    var userLookupPath = '/api/v1/users/' + userID;
    $.getJSON(userLookupPath)
      .then(function( resp ) {
        self.setState({ user: resp.data })
      })
      .fail(function() {
        Alerts.add('danger', 'Unable to retrieve your account details at this time. Please try again.').update();
      });
  }

  handleCreateMeal() {
    window.location.assign('/#/users/' + this.props.userID + '/meals/new');
  }

  handleFilterFormSubmit(filterAttrs) {
    this.setState({ mealFilters: filterAttrs });
  }

  render() {
    var introMsg = 'Your account details will be loaded shortly...';
    if (this.state.user) {
      var user = this.state.user;
      introMsg = 'You\'ve recorded ' + user.meal_count + ' total meals, ' +
                 'totalling ' + user.calorie_total + ' calories. ' +
                 'Your daily target is to consume no more than ' + user.daily_calorie_target + ' calories.';
    }
    return (
      <div>
        <div className="intro">
          <div>
            <div className="pull-left"
                 style={{margin:'0.6rem'}}>
              {introMsg}
            </div>
            <span className="pull-right">
              <input type="button" value="Add Meal" className="btn btn-success" onClick={this.handleCreateMeal.bind(this)} />
            </span>
          </div>
          <div className="clearfix"></div>
        </div>
        <div>
          <MealFilterForm handleFormSubmit={this.handleFilterFormSubmit.bind(this)}
                          filters={this.state.mealFilters} />
        </div>
        <MealList user={this.state.user}
                  filters={this.state.mealFilters} />
      </div>
    );
  }

};