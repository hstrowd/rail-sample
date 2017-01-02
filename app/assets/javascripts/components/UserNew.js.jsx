class UserNew extends React.Component {
  constructor(props) {
    super(props);

    var currentDate = new Date();
    this.state = {
      name: (this.props.name || ''),
      email: (this.props.email || ''),
      password: '',
      passwordConfirmation: '',
      dailyCalorieTarget: (this.props.dailyCalorieTarget || '')
    };
  }

  updateName(event) {
    this.setState({ name: event.target.value });
  }
  updateEmail(event) {
    this.setState({ email: event.target.value });
  }
  updatePassword(event) {
    this.setState({ password: event.target.value });
  }
  updatePasswordConfirmation(event) {
    this.setState({ passwordConfirmation: event.target.value });
  }
  updateDailyCalorieTarget(event) {
    this.setState({ dailyCalorieTarget: event.target.value });
  }

  handleFormSubmit(formValues) {
    Alerts.add('info', 'Creating account....').update();

    var userAttrs = {
      name: formValues.name,
      email: formValues.email,
      password: formValues.password,
      role: formValues.role,
      daily_calorie_target: formValues.dailyCalorieTarget
    };
    this.createUser(userAttrs);
  }

  createUser(data) {
    var self = this;

    var path = '/api/v1/users'
    $.ajax({
      type: "POST",
      url: path,
      data: data
    })
    .done(function() {
      self.handleSuccess(data);
    })
    .fail(function() {
      self.handleFailure();
    });
  }

  handleSuccess(data) {
    if (!$.auth.user.id || ($.auth.user.role == BASIC_ROLE)) {
      $.auth.emailSignIn({ email: data.email, password: data.password })
        .then(function() {
          Alerts.add('success', 'Account created successfully.');
          window.location.assign('/#/dashboard');
        })
        .fail(function() {
          Alerts.add('success', 'Account created. Login to start tracking your calories.');
          window.location.assign('/#/');
        });
    } else {
     Alerts.add('success', 'New user created.');
      window.location.assign('/#/users');
    }
  }
  handleFailure() {
    Alerts.add('danger', 'Unable to create account.').update();
  }

  render() {
    return (
      <div>
        <div className="intro">
          Create a new account by completing the form below:
        </div>
        <UserForm handleFormSubmit={this.handleFormSubmit.bind(this)}
                  userID={null}
                  user={null}
                  submitAction={'Create'}
                  requireCompleteRecord={true} />
    </div>
    );
  }
};