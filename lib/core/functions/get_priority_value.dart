int getPriorityValue(String priority) {
  switch (priority) {
    case 'Low':
      return 2;
    case 'Medium':
      return 1;
    case 'High':
      return 0;
    default:
      return 1;
  }
}

