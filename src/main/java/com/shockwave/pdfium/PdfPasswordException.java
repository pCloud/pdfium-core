package com.shockwave.pdfium;

import java.io.IOException;

import androidx.annotation.Keep;

@Keep
public class PdfPasswordException extends IOException {

    @Keep
    public PdfPasswordException() {
        super();
    }

    @Keep
    public PdfPasswordException(String detailMessage) {
        super(detailMessage);
    }
}
