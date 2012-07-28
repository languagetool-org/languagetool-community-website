package org.languagetool;

import java.io.File;

public class NoDataForLanguageException extends RuntimeException {

    private final Language language;
    private final File indexLocation;

    public NoDataForLanguageException(Language language, File indexLocation) {
        this.language = language;
        this.indexLocation = indexLocation;
    }

    @Override
    public String getMessage() {
        return "No index data found for " + language.getName() + " at " + indexLocation;
    }
}
