'use strict';

describe('RuleEditor services', function() {
  
  beforeEach(module('ruleEditor.services'));

  describe('RuleEditorCtrl', function() {

    it('should find first different position', inject(function(SentenceComparator) {
      var fn = SentenceComparator.findFirstDifferentPosition;
      
      expect(fn([], [])).toBe(-1);
      
      expect(fn([], ['a'])).toBe(-1);
      expect(fn(['a'], [])).toBe(-1);
      
      expect(fn(['a'], ['a'])).toBe(-1);
      expect(fn(['a'], ['b'])).toBe(0);
      
      //TODO: does this make sense?
      expect(fn(['a'], ['a', 'b'])).toBe(-1);
      expect(fn(['a', 'b'], ['a'])).toBe(-1);
      
      expect(fn(['a', 'b'], ['a', 'b'])).toBe(-1);
      expect(fn(['a', 'b'], ['a', 'X'])).toBe(1);

      expect(fn(['a', 'b', 'c'], ['a', 'b', 'c'])).toBe(-1);
      expect(fn(['a', 'b', 'c'], ['a', 'X', 'c'])).toBe(1);
      expect(fn(['a', 'b', 'c'], ['a', 'B', 'c'])).toBe(1);
      expect(fn(['a', 'b', 'c'], ['a', 'b', 'X'])).toBe(2);
      
    }));

    it('should find last different position', inject(function(SentenceComparator) {
      var fn = SentenceComparator.findLastDifferentPosition;
      
      expect(fn([], [])).toBe(-1);
      
      expect(fn([], ['a'])).toBe(-1);
      expect(fn(['a'], [])).toBe(-1);
      
      expect(fn(['a'], ['a'])).toBe(-1);
      //expect(fn(['a'], ['b'])).toBe(0);  //TODO
      
      expect(fn(['a', 'b'], ['a', 'b'])).toBe(-1);
      expect(fn(['a', 'b'], ['a', 'X'])).toBe(1);

      expect(fn(['a', 'b', 'c'], ['a', 'b', 'c'])).toBe(-1);
      expect(fn(['a', 'b', 'c'], ['a', 'X', 'X'])).toBe(2);
      expect(fn([0,1,2,3], [9,9,2,3])).toBe(1);
      expect(fn([0,1,2,3], [9,9,9,3])).toBe(2);
      expect(fn([0,1,2,3], [9,9,9,9])).toBe(3);
      
    }));

    it('should find potential error tokens', inject(function(SentenceComparator) {
      
      expect(SentenceComparator.getErrorTokens([1, 2], [1, 9])).toEqual([2]);
      // doesn't really make sense, does it?:
      expect(SentenceComparator.getErrorTokens([1, 2, 3], [1, 9])).toEqual([2, 3]);
      expect(SentenceComparator.getErrorTokens([1, 2, 3, 4], [1, 9])).toEqual([2, 3, 4]);
      
      expect(SentenceComparator.getErrorTokens([1, 2, 3], [1, 9, 3])).toEqual([2]);
      expect(SentenceComparator.getErrorTokens([1, 2, 3], [1, 9, 9])).toEqual([2, 3]);
      expect(SentenceComparator.getErrorTokens([1, 2, 3], [9, 9, 3])).toEqual([1, 2]);
      expect(SentenceComparator.getErrorTokens([1, 2, 3], [9, 9, 9])).toEqual([1, 2, 3]);
      
    }));

  });
});
