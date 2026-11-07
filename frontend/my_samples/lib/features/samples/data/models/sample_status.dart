enum SampleStatus {
  pendingApproval('Pending Approval'),
  approved('Approved Samples'),
  pendingCriteria('Posted Samples');

  final String label;
  const SampleStatus(this.label);
}
