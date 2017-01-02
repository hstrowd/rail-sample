class MealList extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      user: (this.props.user || {}),
      dailyCalorieTarget: ((this.props.user && this.props.user.daily_calorie_target) || null),
      filters: (this.props.filters || {}),
      meals: []
    };
  }

  componentWillMount() {
    this.retrieveMeals(this.state.user.id, this.state.filters);
  }

  componentWillReceiveProps(nextProps) {
    var newFilters = null;
    if (nextProps.filters != this.props.filters) {
      newFilters = nextProps.filters;
    }
    var newUser = null;
    if (nextProps.user != this.props.user) {
      newUser = nextProps.user;
      this.setState({
        user: nextProps.user,
        dailyCalorieTarget: (nextProps.user.daily_calorie_target || null)
      });
    }
    if(newFilters || newUser) {
      newUser = newUser || this.state.user;
      newFilters = newFilters || this.props.filters;
      this.retrieveMeals(newUser.id, newFilters);
    }
  }

  retrieveMeals(userID, filters) {
    var self = this;

    var queryParams = [];
    if (userID) {
      queryParams.push('user_id=' + userID);
    }
    if (filters.startDate) {
      var startDate = moment(filters.startDate).startOf('day').format();
      queryParams.push('start_date=' + startDate);
    }
    if (filters.endDate) {
      var endDate = moment(filters.endDate).endOf('day').format();
      queryParams.push('end_date=' + endDate);
    }
    // Account for the timezone offset.
    if (filters.startHour || filters.endHour) {
      var utcHourOffset = Math.round(moment().utcOffset() / 60);
      var startHour = (parseInt(filters.startHour) || 0 );
      startHour -= utcHourOffset;
      startHour %= 24;

      var endHour = (parseInt(filters.endHour) || 0 );
      endHour -= utcHourOffset;
      endHour %= 24;

      queryParams.push('start_hour=' + startHour);
      queryParams.push('end_hour=' + endHour);
    }
    queryString = queryParams.join('&')

    var mealSearchPath = '/api/v1/meals?' + queryString;
    $.getJSON(mealSearchPath)
      .then(function( resp ) {
        self.setState({ meals: resp.data })
      })
      .fail(function() {
        Alerts.add('danger', 'Unable to retrieve your meals at this time.').update();
      });
  }

  render() {
    if (!this.state.user) { return null; }

    var self = this;
    var mealList = [];
    if ( this.state.meals.length > 0 ) {
      var dates = {};
      this.state.meals.forEach(function (meal) {
        meal.date = moment(meal.occurred_at).format('dddd, MMMM Do YYYY')
        meal.time = moment(meal.occurred_at).format('h:mm a')
        if ( dates[meal.date] == null ) {
          dates[meal.date] = [];
        }
        dates[meal.date].push(meal);
      });

      $.each(dates, function(dateString, meals) {
        mealList.push(self.renderDateContainer(dateString, meals));
      });
    } else {
      var alertStyles = {
        float: 'none',
        margin: '1rem auto'
      };
      mealList = (
        <div className="alert alert-info col-md-7 text-center"
             style={alertStyles}>
          No meals recorded yet. <Link to={`/users/${this.state.user.id}/meals/new`}>Click here</Link> to record your first meal.
        </div>
      );
    }

    return (
      <div className="meals">
        {mealList}
      </div>
    );
  }


  renderDateContainer(dateString, meals) {
    var dateMeals = [];
    var calorieTotal = 0;
    var date = moment(meals[0].occurred_at);
    meals
      .sort(function(m1, m2) { return m1.occurred_at >= m2.occurred_at })
      .forEach(function(meal) {
        dateMeals.push(<MealPreview key={meal.id} meal={meal} />);
        calorieTotal += meal.calories;
      });

    var dailyLimitClass = '';
    if (calorieTotal > this.state.dailyCalorieTarget) {
      dailyLimitClass = 'bg-danger'
    } else {
      if ( moment().startOf('day') < date ) {
        dailyLimitClass = 'bg-info'
      } else {
        dailyLimitClass = 'bg-success'
      }
    }

    return (
      <div key={'date-meals-' + date.format('YYYY-MM-DD')}
           className={'meal-date ' + dailyLimitClass}>
        <div className="date-title">
          <div className="pull-left"><h3>{dateString}</h3></div>
          <div className="badge pull-right">{calorieTotal} Calories</div>
          <div className="clearfix"></div>
        </div>
        <div>
          {dateMeals}
        </div>
        <div className="clearfix"></div>
      </div>
    );
  }
};

