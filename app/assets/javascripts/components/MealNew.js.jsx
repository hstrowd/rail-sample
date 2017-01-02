class MealNew extends React.Component {
  constructor(props) {
    super(props);
  }

  handleFormSubmit(formValues) {
    Alerts.add('info', 'Recording meal....').update();

    var mealAttrs = {
      user_id: this.props.params.userID,
      description: formValues.description,
      calories: formValues.calories,
      occurred_at: moment(formValues.date + ' ' + formValues.time,
                          MealForm.DATE_FORMAT + ' ' + MealForm.TIME_FORMAT).format()
    };
    this.recordMeal(mealAttrs);
  }

  recordMeal(mealAttrs) {
    var self = this;

    var path = '/api/v1/meals'
    $.ajax({
      type: "POST",
      url: path,
      data: mealAttrs
    })
    .done(function() {
      self.handleSuccess();
    })
    .fail(function() {
      self.handleFailure();
    });
  }

  handleSuccess() {
    Alerts.add('success', 'Successfully recorded new meal.');
    var redirectPath = '/#/dashboard';
    if ($.auth.user.id != this.props.params.userID) {
      redirectPath = '/#/users/' + this.props.params.userID;
    }
    window.location.assign(redirectPath);
  }
  handleFailure() {
    Alerts.add('danger', 'Unable to record the meal. Please try again.').update();
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

    return (
      <div>
        <div className="intro">
          Record a new meal using the form below:
        </div>
        <MealForm handleFormSubmit={this.handleFormSubmit.bind(this)}
                  userID={this.props.userID}
                  meal={{}}
                  submitAction={'Create'} />
    </div>
    );
  }
};