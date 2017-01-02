class MealEdit extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      meal: null
    };
  }

  componentWillMount() {
    if (!$.auth.user.id ||
        ($.auth.user.role == BASIC_ROLE && $.auth.user.id != this.props.params.userID)) {
      return;
    }

    this.retrieveMeal(this.props.params.mealID);
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.params.mealID != this.props.params.mealID) {
      this.retrieveMeal(nextProps.params.mealID);
    }
  }

  retrieveMeal(mealID) {
    var self = this;
    var mealLookupPath = '/api/v1/meals/' + mealID;
    $.getJSON(mealLookupPath)
      .then(function( resp ) {
        self.setState({ meal: resp.data })
      })
      .fail(function() {
        Alerts.add('danger', 'Unable to modify the meal at this time. Please try again.');
        window.location.assign('/#/dashboard');
      });
  }

  handleFormSubmit(formValues) {
    Alerts.add('info', 'Updating meal....').update();

    var mealAttrs = {
      description: formValues.description,
      calories: formValues.calories,
      occurred_at: moment(formValues.date + ' ' + formValues.time,
                          MealForm.DATE_FORMAT + ' ' + MealForm.TIME_FORMAT).format()
    };
    this.updateMeal(this.props.params.mealID, mealAttrs);
  }

  updateMeal(mealID, mealAttrs) {
    var self = this;

    var path = '/api/v1/meals/' + mealID;
    $.ajax({
      type: "PUT",
      url: path,
      data: mealAttrs
    })
    .done(function() {
      self.handleUpdateSuccess();
    })
    .fail(function() {
      self.handleUpdateFailure();
    });
  }

  handleUpdateSuccess() {
    Alerts.add('success', 'Successfully updated the meal.');
    this.redirectBackToUser();
  }
  handleUpdateFailure() {
    Alerts.add('danger', 'Unable to update the meal.').update();
  }

  handleDeleteMeal() {
    Alerts.add('danger', 'Deleting meal....').update();

    this.deleteMeal(this.props.params.mealID);
  }

  deleteMeal(mealID) {
    var self = this;

    var path = '/api/v1/meals/' + mealID
    $.ajax({
      type: "DELETE",
      url: path
    })
    .done(function() {
      self.handleDeleteSuccess();
    })
    .fail(function() {
      self.handleDeleteFailure();
    });
  }

  handleDeleteSuccess() {
    Alerts.add('success', 'Successfully deleted the meal.');
    this.redirectBackToUser();
  }
  handleDeleteFailure() {
    Alerts.add('danger', 'Unable to delete the meal.').update();
  }

  redirectBackToUser() {
    var redirectPath = '/#/dashboard';
    if ($.auth.user.id != this.props.params.userID) {
      redirectPath = '/#/users/' + this.props.params.userID;
    }
    window.location.assign(redirectPath);
  }

  render() {
    if (!$.auth.user.id) {
      Alerts.add('warning', 'Login required.');
      window.location.assign('/#/');
      return null;
    }
    if ($.auth.user.role != ADMIN_ROLE && $.auth.user.id != this.props.params.userID) {
      Alerts.add('danger', 'Unauthorized Access.');
      window.location.assign('/#/');
      return null;
    }

    var form = '';
    if (this.state.meal) {
      form = (
        <MealForm handleFormSubmit={this.handleFormSubmit.bind(this)}
                  userID={this.props.params.userID}
                  meal={this.state.meal}
                  submitAction={'Update'} />
      );
    }

    return (
      <div>
        <div className="intro">
          <div className="pull-left">Update the meal using the form below:</div>
          <button type="button" className="btn btn-danger pull-right" onClick={this.handleDeleteMeal.bind(this)}>
            Delete Meal
          </button>
          <div className="clearfix"></div>
        </div>
        {form}
    </div>
    );
  }
};