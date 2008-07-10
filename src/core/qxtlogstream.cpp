/****************************************************************************
**
** Copyright (C) Qxt Foundation. Some rights reserved.
**
** This file is part of the QxtCore module of the Qt eXTension library
**
** This library is free software; you can redistribute it and/or modify it
** under the terms of the Common Public License, version 1.0, as published by
** IBM.
**
** This file is provided "AS IS", without WARRANTIES OR CONDITIONS OF ANY
** KIND, EITHER EXPRESS OR IMPLIED INCLUDING, WITHOUT LIMITATION, ANY
** WARRANTIES OR CONDITIONS OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR
** FITNESS FOR A PARTICULAR PURPOSE.
**
** You should have received a copy of the CPL along with this file.
** See the LICENSE file and the cpl1.0.txt file included with the source
** distribution for more information. If you did not receive a copy of the
** license, contact the Qxt Foundation.
**
** <http://libqxt.sourceforge.net>  <foundation@libqxt.org>
**
****************************************************************************/

#include "qxtlogstream.h"
#include "qxtlogger.h"


QxtLogStreamPrivate::QxtLogStreamPrivate( QxtLogger *owner, QxtLogger::LogLevel level, const QList<QVariant> &data) : owner(owner), level(level), refcount(1), data(data)
{
	// Nothing to see here.
}

QxtLogStreamPrivate::~QxtLogStreamPrivate()
{
	owner->log( level, data );
}

QxtLogStream::QxtLogStream( QxtLogger *owner, QxtLogger::LogLevel level, const QList<QVariant> &data) : d(new QxtLogStreamPrivate(owner, level, data)) 
{
	//Nothing here either.
}

QxtLogStream::QxtLogStream( const QxtLogStream &other )
{
	d = other.d;
	d->refcount++;
}

QxtLogStream::~QxtLogStream()
{
	d->refcount--;
	if ( d->refcount == 0 ) delete d;
}

QxtLogStream& QxtLogStream::operator<< ( const QVariant &value )
{
	d->data.append( value );
	return *this;
}

