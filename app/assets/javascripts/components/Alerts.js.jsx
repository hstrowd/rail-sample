class Alerts extends React.Component {
  static add(type, body, timeout = 5) {
    var alerts = JSON.parse(localStorage.getItem('alerts') || '[]');
    alerts.push({ type: type, body: body, timeout: timeout });
    localStorage.setItem('alerts', JSON.stringify(alerts));

    return this; // Allow chaining.
  }

  static update() {
    window.reloadAlerts();

    return this; // Allow chaining.
  }

  componentDidMount() {
      var self = this;
      window.reloadAlerts = function() {
          self.forceUpdate();
      }
  }

  componentWillUnmount() {
      window.reloadAlerts = null;
  }

  render() {
    var alerts = JSON.parse(localStorage.getItem('alerts') || '[]');
    localStorage.setItem('alerts', '[]');

    var alertMsgs = [];
    alerts.forEach((alert) => {
      var key = Math.ceil(Math.random() * 10000);
      var idString = 'status-' + Math.ceil(Math.random() * 10000);
      var classString = 'alert alert-' + alert.type;
      alertMsgs.push(<div key={key} id={idString} className={classString} ref="status">
                       {alert.body}
                     </div>);

      if (alert.timeout) {
        window.setTimeout(function(){
          $('#' + idString).slideUp();
        }, alert.timeout * 1000)
      }
    });

    return (
      <div className="alerts">
        { alertMsgs }
      </div>
    );
  }
};
