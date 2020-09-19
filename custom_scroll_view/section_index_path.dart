class SectionIndexPath {
  int section;
  int index;

  SectionIndexPath(this.section, this.index);

  @override
  bool operator ==(other) {
    if (other is SectionIndexPath) {
      return section == other.section && index == other.section;
    }
    return false;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => section.hashCode ^ index.hashCode;

  @override
  String toString() {
    return '{section: $section, index: $index}';
  }
}
