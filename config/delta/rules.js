export default [
  {
    match: {
      // form of element is {subject, predicate, object}
      subject: {
      }
    },
    callback: {
      url: 'http://search/update',
      method: 'POST'
    },
    options: {
      resourceFormat: 'v0.0.0-genesis',
      gracePeriod: 10000,
      ignoreFromSelf: true
    }
  },
  {
    match: {
      // form of element is {subject, predicate, object}
      subject: {
      }
    },
    callback: {
      url: 'http://resource/.mu/delta',
      method: 'POST'
    },
    options: {
      resourceFormat: 'v0.0.1',
      gracePeriod: 250,
      ignoreFromSelf: true
    }
  }
];
